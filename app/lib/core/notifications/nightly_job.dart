import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../../features/places/data/place.dart';
import '../../features/places/data/place_repository.dart';
import '../../features/plan/data/plan_repository.dart';
import '../../features/plan/data/trip.dart';
import '../../features/plan/data/trip_planner.dart';
import '../../features/settings/data/prefs.dart';
import '../api/directions_source.dart';
import '../db/app_database.dart';
import '../utils/time_utils.dart';
import 'notification_service.dart';

const nightlyTask = 'nightly_plan';

class NightlySummary {
  NightlySummary(this.tripCount, {this.firstLeave, this.firstFrom, this.firstTo, this.firstArrive, this.failed = 0});
  final int tripCount;
  final DateTime? firstLeave, firstArrive;
  final String? firstFrom, firstTo;
  final int failed; // trips whose route could not be refreshed

  String get title =>
      tripCount == 0 ? 'Nothing planned for tomorrow' : '$tripCount trip${tripCount > 1 ? 's' : ''} tomorrow';

  /// Same leave time the card and the timeline show.
  String get body {
    if (tripCount == 0) return 'Add a trip and the route arrives at night.';
    if (firstLeave == null) return 'First: $firstFrom → $firstTo · route unavailable, check the app';
    final arrive = firstArrive != null ? ' (arrive ${fmtTime(firstArrive!)})' : '';
    return 'First: leave $firstFrom at ${fmtTime(firstLeave!)} for $firstTo$arrive';
  }
}

/// The work the nightly job does: fetch every trip for tomorrow, cache the
/// best route + leave time, mark trips notified. Shared by the background job
/// and the "Run nightly job now" button.
Future<NightlySummary> runNightlyPlan(AppDatabase db, DirectionsSource client, Prefs prefs, {DateTime? now}) async {
  final tomorrow = tomorrowDate(now);
  final plans = PlanRepository(db);
  final places = PlaceRepository(db);
  final trips = await plans.tripsOn(tomorrow);
  if (trips.isEmpty) return NightlySummary(0);

  final byId = {for (final p in await places.all()) p.id: p};
  var failed = 0;
  for (final trip in trips) {
    final from = byId[trip.fromPlaceId], to = byId[trip.toPlaceId];
    try {
      if (from == null || to == null) throw StateError('place missing');
      final r = await planTrip(trip, from: from, to: to, client: client, prefs: prefs, now: now);
      if (r == null) failed++;
    } catch (_) {
      failed++; // keep whatever route was cached before
    }
    trip.status = TripStatus.notified;
  }
  await db.transaction(() async {
    for (final t in trips) {
      await plans.save(t);
    }
  });
  trips.sort((a, b) => (a.leaveAt ?? a.arriveBy).compareTo(b.leaveAt ?? b.arriveBy));
  final first = trips.first;
  final route = cachedRoute(first);
  Place? p(int id) => byId[id];
  return NightlySummary(
    trips.length,
    firstLeave: first.leaveAt,
    firstArrive: route?.arriveAt,
    firstFrom: p(first.fromPlaceId)?.name,
    firstTo: p(first.toPlaceId)?.name,
    failed: failed,
  );
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, _) async {
    if (task != nightlyTask) return true;
    WidgetsFlutterBinding.ensureInitialized();
    final db = AppDatabase(); // same SQLite file as the UI (WAL + busy timeout)
    try {
      final prefs = await PrefsStore.load();
      final summary = await runNightlyPlan(db, directionsFromEnv(), prefs);
      if (summary.tripCount > 0) {
        await NotificationService.show(title: summary.title, body: summary.body, payload: 'tomorrow');
      }
      await scheduleNextRun(prefs.notifyHour, prefs.notifyMinute);
      return true;
    } catch (e) {
      return false; // workmanager retries with the backoff policy
    } finally {
      await db.close();
    }
  });
}

DateTime nextRunAt(int hour, int minute, DateTime now) {
  var next = DateTime(now.year, now.month, now.day, hour, minute);
  if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
  return next;
}

/// Background work only exists on Android/iOS; callers check [backgroundJobsSupported].
bool get backgroundJobsSupported => !kIsWeb;

Future<void> scheduleNextRun(int hour, [int minute = 0]) async {
  if (!backgroundJobsSupported) return;
  final now = DateTime.now();
  await Workmanager().registerOneOffTask(
    nightlyTask,
    nightlyTask,
    initialDelay: nextRunAt(hour, minute, now).difference(now),
    existingWorkPolicy: ExistingWorkPolicy.replace,
    constraints: Constraints(networkType: NetworkType.connected),
    backoffPolicy: BackoffPolicy.linear,
    backoffPolicyDelay: const Duration(minutes: 10),
  );
}
