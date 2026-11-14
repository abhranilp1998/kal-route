import 'package:shared_preferences/shared_preferences.dart';

import '../../features/places/data/place.dart';
import '../../features/places/data/place_repository.dart';
import '../../features/plan/data/plan_repository.dart';
import '../../features/plan/data/trip.dart';
import '../../features/plan/data/trip_planner.dart';
import '../../features/settings/data/prefs.dart';
import '../api/directions_source.dart';
import '../utils/time_utils.dart';
import 'app_database.dart';

/// EXAMPLE DATA offered on first launch so the app is usable straight away.
/// Coordinates are real Kolkata locations; the people/addresses are examples.
List<Place> examplePlaces() => [
  Place(name: 'Home', emoji: '🏠', lat: 22.5203, lng: 88.3468, address: 'Lake Road, Kalighat'),
  Place(name: 'College', emoji: '🎓', lat: 22.5867, lng: 88.4171, address: 'Sector II, Salt Lake'),
  Place(name: 'Gym', emoji: '🏋️', lat: 22.5880, lng: 88.4085, address: 'City Centre, Salt Lake'),
  Place(name: "Mom's place", emoji: '👵', lat: 22.4980, lng: 88.3105, address: 'Diamond Harbour Rd, Behala'),
];

const _seededKey = 'example_seeded_v2';

/// Seeds example places + two trips for tomorrow, once per install, and only
/// into an empty database.
Future<void> seedIfNeeded(AppDatabase db, DirectionsSource client, Prefs prefs, {SharedPreferences? sp}) async {
  final store = sp ?? await SharedPreferences.getInstance();
  if (store.getBool(_seededKey) ?? false) return;
  final places = PlaceRepository(db);
  if ((await places.all()).isEmpty) await seedExampleData(db, client, prefs);
  await store.setBool(_seededKey, true);
}

Future<void> seedExampleData(AppDatabase db, DirectionsSource client, Prefs prefs) async {
  final places = PlaceRepository(db);
  final plan = PlanRepository(db);
  final saved = <Place>[];
  for (final p in examplePlaces()) {
    saved.add(await places.save(p));
  }
  final day = tomorrowDate();
  final trips = [
    Trip(date: day, fromPlaceId: saved[0].id, toPlaceId: saved[1].id, arriveBy: atTime(day, 10, 0)),
    Trip(date: day, fromPlaceId: saved[1].id, toPlaceId: saved[2].id, arriveBy: atTime(day, 17, 45)),
  ];
  for (final t in trips) {
    try {
      await planTrip(
        t,
        from: saved.firstWhere((p) => p.id == t.fromPlaceId),
        to: saved.firstWhere((p) => p.id == t.toPlaceId),
        client: client,
        prefs: prefs,
      );
    } catch (_) {
      /* fetched later by the nightly job or the refresh button */
    }
    await plan.save(t);
  }
}

/// Settings → "Reset example data": wipes places + trips and re-seeds.
Future<void> resetExampleData(AppDatabase db, DirectionsSource client, Prefs prefs) async {
  await db.transaction(() async {
    await db.delete(db.trips).go();
    await db.delete(db.places).go();
  });
  await seedExampleData(db, client, prefs);
}
