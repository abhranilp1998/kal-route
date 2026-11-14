import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/places/data/place.dart';
import '../../features/places/data/place_repository.dart';
import '../../features/plan/data/plan_repository.dart';
import '../../features/plan/data/trip.dart';
import 'app_database.dart';

/// One-time migration from the first build, which kept places and trips as
/// JSON lists in shared_preferences. Runs inside one transaction and removes
/// the old keys only after the import committed. Returns the number of rows
/// imported (0 when there was nothing to import).
Future<int> importLegacyPrefsData(AppDatabase db, SharedPreferences sp) async {
  const placesKey = 'places_v1', tripsKey = 'trips_v1', seededKey = 'seeded_v1';
  final rawPlaces = sp.getString(placesKey);
  final rawTrips = sp.getString(tripsKey);
  if (rawPlaces == null && rawTrips == null) return 0;

  var count = 0;
  await db.transaction(() async {
    final places = PlaceRepository(db);
    final plans = PlanRepository(db);
    final idMap = <int, int>{};
    for (final j in (jsonDecode(rawPlaces ?? '[]') as List).cast<Map<String, dynamic>>()) {
      final legacy = Place.fromLegacyJson(j);
      final saved = await places.save(legacy.copyWith(id: 0));
      idMap[legacy.id] = saved.id;
      count++;
    }
    for (final j in (jsonDecode(rawTrips ?? '[]') as List).cast<Map<String, dynamic>>()) {
      final t = Trip.fromLegacyJson(j);
      final from = idMap[t.fromPlaceId], to = idMap[t.toPlaceId];
      if (from == null || to == null) continue; // orphan trip, skip
      t
        ..fromPlaceId = from
        ..toPlaceId = to;
      await plans.save(t);
      count++;
    }
  });
  await sp.remove(placesKey);
  await sp.remove(tripsKey);
  await sp.remove(seededKey);
  return count;
}
