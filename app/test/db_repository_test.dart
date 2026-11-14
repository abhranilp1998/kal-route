import 'dart:convert';

import 'package:commute_planner/core/api/mock_directions_client.dart';
import 'package:commute_planner/core/db/app_database.dart';
import 'package:commute_planner/core/db/legacy_import.dart';
import 'package:commute_planner/core/db/seed.dart';
import 'package:commute_planner/core/notifications/nightly_job.dart';
import 'package:commute_planner/core/utils/time_utils.dart';
import 'package:commute_planner/features/places/data/place.dart';
import 'package:commute_planner/features/places/data/place_repository.dart';
import 'package:commute_planner/features/plan/data/plan_repository.dart';
import 'package:commute_planner/features/plan/data/trip.dart';
import 'package:commute_planner/features/settings/data/prefs.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase db;
  late PlaceRepository places;
  late PlanRepository plans;
  const mock = MockDirectionsClient(latency: Duration.zero);

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
    places = PlaceRepository(db);
    plans = PlanRepository(db);
  });
  tearDown(() => db.close());

  Future<(Place, Place)> twoPlaces() async => (
        await places.save(Place(name: 'Home', lat: 22.52, lng: 88.34, emoji: '🏠')),
        await places.save(Place(name: 'College', lat: 22.58, lng: 88.41)),
      );

  group('PlaceRepository', () {
    test('insert assigns ids, update keeps id, delete removes', () async {
      final (home, college) = await twoPlaces();
      expect(home.id, isNot(0));
      expect(college.id, greaterThan(home.id));
      await places.save(home.copyWith(name: 'Home (new)', address: 'Lake Road'));
      final reloaded = await places.byId(home.id);
      expect(reloaded!.name, 'Home (new)');
      expect(reloaded.address, 'Lake Road');
      expect(reloaded.emoji, '🏠');
      await places.delete(college.id);
      expect((await places.all()).map((p) => p.name), ['Home (new)']);
    });

    test('watchAll emits on change', () async {
      final emissions = <int>[];
      final sub = places.watchAll().listen((l) => emissions.add(l.length));
      await pumpEventQueue();
      await places.save(Place(name: 'Gym', lat: 1, lng: 2));
      await pumpEventQueue();
      await sub.cancel();
      expect(emissions, [0, 1]);
    });

    test('name length is validated', () async {
      expect(() => places.save(Place(name: '', lat: 0, lng: 0)), throwsA(isA<InvalidDataException>()));
    });
  });

  group('PlanRepository', () {
    test('tripsOn returns only that local day, ordered by arriveBy', () async {
      final (home, college) = await twoPlaces();
      final day = DateTime(2026, 11, 16);
      await plans.save(Trip(date: day, fromPlaceId: college.id, toPlaceId: home.id, arriveBy: atTime(day, 18, 0)));
      await plans.save(Trip(date: day, fromPlaceId: home.id, toPlaceId: college.id, arriveBy: atTime(day, 10, 0)));
      final next = day.add(const Duration(days: 1));
      await plans.save(Trip(date: next, fromPlaceId: home.id, toPlaceId: college.id, arriveBy: atTime(next, 0, 5)));
      final onDay = await plans.tripsOn(DateTime(2026, 11, 16, 23, 59));
      expect(onDay.map((t) => t.arriveBy.hour), [10, 18]);
      expect(await plans.tripsOn(next), hasLength(1));
    });

    test('round-trips every column, including enum status and route json', () async {
      final (home, college) = await twoPlaces();
      final day = DateTime(2026, 11, 16);
      final t = await plans.save(Trip(
        date: day,
        fromPlaceId: home.id,
        toPlaceId: college.id,
        arriveBy: atTime(day, 10, 0),
        status: TripStatus.notified,
        leaveAt: atTime(day, 9, 7),
        bufferMinutes: 5,
        cachedRouteJson: '{"x":1}',
        routeFetchedAt: DateTime(2026, 11, 15, 21),
        routeSource: 'example',
      ));
      final back = (await plans.byId(t.id))!;
      expect(back.status, TripStatus.notified);
      expect(back.leaveAt, atTime(day, 9, 7));
      expect(back.bufferMinutes, 5);
      expect(back.cachedRouteJson, '{"x":1}');
      expect(back.routeFetchedAt, DateTime(2026, 11, 15, 21));
      expect(back.routeSource, 'example');
    });

    test('deleting a place cascades to its trips (foreign keys on)', () async {
      final (home, college) = await twoPlaces();
      final day = DateTime(2026, 11, 16);
      await plans.save(Trip(date: day, fromPlaceId: home.id, toPlaceId: college.id, arriveBy: atTime(day, 10, 0)));
      await places.delete(college.id);
      expect(await plans.all(), isEmpty);
    });

    test('trip with unknown place is rejected by the foreign key', () async {
      final day = DateTime(2026, 11, 16);
      expect(() => plans.save(Trip(date: day, fromPlaceId: 98, toPlaceId: 99, arriveBy: day)),
          throwsA(isA<SqliteException>()));
    });
  });

  test('schema has the trip date and status indexes', () async {
    final rows = await db.customSelect("SELECT name FROM sqlite_master WHERE type = 'index' AND tbl_name = 'trips'").get();
    expect(rows.map((r) => r.read<String>('name')), containsAll(['trips_date_idx', 'trips_status_idx']));
    final plan = await db
        .customSelect('EXPLAIN QUERY PLAN SELECT * FROM trips WHERE date >= ? AND date < ?',
            variables: [Variable.withInt(0), Variable.withInt(1)])
        .get();
    expect(plan.map((r) => r.data['detail'].toString()).join(' '), contains('trips_date_idx'));
  });

  group('legacy shared_preferences import', () {
    test('imports places and trips, remaps ids, removes old keys', () async {
      final day = DateTime(2026, 11, 16);
      SharedPreferences.setMockInitialValues({
        'places_v1': jsonEncode([
          {'id': 7, 'name': 'Home', 'lat': 22.5, 'lng': 88.3, 'address': 'Kalighat', 'emoji': '🏠'},
          {'id': 9, 'name': 'College', 'lat': 22.6, 'lng': 88.4, 'address': null, 'emoji': '🎓'},
        ]),
        'trips_v1': jsonEncode([
          {'id': 1, 'date': day.toIso8601String(), 'fromPlaceId': 7, 'toPlaceId': 9,
            'arriveBy': atTime(day, 10, 0).toIso8601String(), 'status': 'planned', 'leaveAt': null, 'cachedRouteJson': null},
          {'id': 2, 'date': day.toIso8601String(), 'fromPlaceId': 7, 'toPlaceId': 55,
            'arriveBy': atTime(day, 11, 0).toIso8601String(), 'status': 'planned', 'leaveAt': null, 'cachedRouteJson': null},
        ]),
        'seeded_v1': true,
      });
      final sp = await SharedPreferences.getInstance();
      final n = await importLegacyPrefsData(db, sp);
      expect(n, 3); // 2 places + 1 trip (orphan skipped)
      final ps = await places.all();
      final trips = await plans.all();
      expect(trips.single.fromPlaceId, ps.firstWhere((p) => p.name == 'Home').id);
      expect(trips.single.toPlaceId, ps.firstWhere((p) => p.name == 'College').id);
      expect(sp.getString('places_v1'), isNull);
      expect(await importLegacyPrefsData(db, sp), 0); // idempotent
    });
  });

  group('seed + nightly job against the database', () {
    test('seeds once, nightly plan updates every trip for tomorrow', () async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      await seedIfNeeded(db, mock, Prefs(), sp: sp);
      await seedIfNeeded(db, mock, Prefs(), sp: sp); // no duplicates
      expect(await places.all(), hasLength(4));
      final before = await plans.tripsOn(tomorrowDate());
      expect(before, hasLength(2));
      expect(before.every((t) => t.status == TripStatus.planned), isTrue);

      final s = await runNightlyPlan(db, mock, Prefs(bufferMinutes: 7));
      expect(s.tripCount, 2);
      expect(s.failed, 0);
      final after = await plans.tripsOn(tomorrowDate());
      expect(after.every((t) => t.status == TripStatus.notified), isTrue);
      expect(after.every((t) => t.bufferMinutes == 7 && t.leaveAt != null && t.routeSource == 'example'), isTrue);
      expect(s.body, contains('leave Home at'));
      expect(s.body, contains('for College'));
    });

    test('nightly plan with no trips', () async {
      final s = await runNightlyPlan(db, mock, Prefs());
      expect(s.tripCount, 0);
      expect(s.title, 'Nothing planned for tomorrow');
    });
  });
}
