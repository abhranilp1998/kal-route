import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/directions_source.dart';
import '../core/db/app_database.dart';
import '../core/geo/geocoding_service.dart';
import '../core/geo/location_service.dart';
import '../core/utils/time_utils.dart';
import '../features/places/data/place.dart';
import '../features/places/data/place_repository.dart';
import '../features/plan/data/plan_repository.dart';
import '../features/plan/data/trip.dart';
import '../features/plan/data/trip_planner.dart';
import '../features/settings/data/prefs.dart';

/// Overridden in bootstrap() with the opened database.
final databaseProvider = Provider<AppDatabase>((ref) => throw UnimplementedError('override databaseProvider'));
final initialPrefsProvider = Provider<Prefs>((ref) => Prefs());
final directionsProvider = Provider<DirectionsSource>((ref) => directionsFromEnv());
final geocoderProvider = Provider<NominatimGeocoder>((ref) => NominatimGeocoder());
final locationServiceProvider = Provider<LocationService>((ref) => const LocationService());

final placeRepoProvider = Provider((ref) => PlaceRepository(ref.watch(databaseProvider)));
final planRepoProvider = Provider((ref) => PlanRepository(ref.watch(databaseProvider)));

class PrefsNotifier extends Notifier<Prefs> {
  @override
  Prefs build() => ref.watch(initialPrefsProvider);

  Future<void> update(Prefs p) async {
    state = p;
    await PrefsStore.save(p);
  }
}

final prefsProvider = NotifierProvider<PrefsNotifier, Prefs>(PrefsNotifier.new);

/// Live list of saved places (drift watch query).
final placesStreamProvider = StreamProvider<List<Place>>((ref) => ref.watch(placeRepoProvider).watchAll());
final placesProvider = Provider<List<Place>>((ref) => ref.watch(placesStreamProvider).value ?? const []);

/// Live list of tomorrow's trips, ordered by leave time.
final tomorrowTripsStreamProvider = StreamProvider<List<Trip>>(
    (ref) => ref.watch(planRepoProvider).watchTripsOn(tomorrowDate()).map((trips) => trips
      ..sort((a, b) => (a.leaveAt ?? a.arriveBy).compareTo(b.leaveAt ?? b.arriveBy))));
final tomorrowTripsProvider =
    Provider<List<Trip>>((ref) => ref.watch(tomorrowTripsStreamProvider).value ?? const []);

final tripProvider = StreamProvider.family<Trip?, int>((ref, id) => ref.watch(planRepoProvider).watchById(id));

/// Write-side actions. Reads go through the stream providers above, which
/// update automatically when the database changes.
class PlanActions {
  PlanActions(this.ref);
  final Ref ref;

  Future<void> savePlace(Place p) => ref.read(placeRepoProvider).save(p);
  Future<void> deletePlace(int id) => ref.read(placeRepoProvider).delete(id);

  /// Plans the route for [trip] (if possible) and saves it.
  Future<Trip> addTrip(Trip trip) async {
    await _plan(trip, rethrowErrors: false);
    return ref.read(planRepoProvider).save(trip);
  }

  /// Re-fetches the route; errors propagate so the UI can show them.
  Future<void> replan(int id) async {
    final t = await ref.read(planRepoProvider).byId(id);
    if (t == null) return;
    await _plan(t, rethrowErrors: true);
    await ref.read(planRepoProvider).save(t);
  }

  Future<void> deleteTrip(int id) => ref.read(planRepoProvider).delete(id);

  Future<void> _plan(Trip t, {required bool rethrowErrors}) async {
    final places = ref.read(placeRepoProvider);
    final from = await places.byId(t.fromPlaceId), to = await places.byId(t.toPlaceId);
    if (from == null || to == null) return;
    try {
      await planTrip(t, from: from, to: to, client: ref.read(directionsProvider), prefs: ref.read(prefsProvider));
    } catch (_) {
      if (rethrowErrors) rethrow;
    }
  }
}

final planActionsProvider = Provider((ref) => PlanActions(ref));
