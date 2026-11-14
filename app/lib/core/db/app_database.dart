import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:drift_flutter/drift_flutter.dart';

import '../../features/plan/data/trip.dart' show TripStatus;

part 'app_database.g.dart';

/// Saved places (Home, College, ...).
@DataClassName('PlaceRow')
class Places extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  TextColumn get address => text().nullable()();
  TextColumn get emoji => text().withDefault(const Constant('📍'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Planned trips. Indexed by day because every screen and the nightly job
/// query "trips on date X".
@DataClassName('TripRow')
@TableIndex(name: 'trips_date_idx', columns: {#date})
@TableIndex(name: 'trips_status_idx', columns: {#status})
class Trips extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Local midnight of the trip day.
  DateTimeColumn get date => dateTime()();
  @ReferenceName('departingTrips')
  IntColumn get fromPlaceId => integer().references(Places, #id, onDelete: KeyAction.cascade)();
  @ReferenceName('arrivingTrips')
  IntColumn get toPlaceId => integer().references(Places, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get arriveBy => dateTime()();
  TextColumn get status => textEnum<TripStatus>().withDefault(Constant(TripStatus.planned.name))();

  /// When to walk out of the door = route departure − [bufferMinutes].
  DateTimeColumn get leaveAt => dateTime().nullable()();

  /// Buffer used when [leaveAt] was computed, so the timeline can show it.
  IntColumn get bufferMinutes => integer().withDefault(const Constant(0))();

  /// Best route as JSON (RouteResult.toJson) so the card works offline.
  TextColumn get routeJson => text().nullable()();
  DateTimeColumn get routeFetchedAt => dateTime().nullable()();
  TextColumn get routeSource => text().nullable()(); // 'google' | 'example'
}

@DriftDatabase(tables: [Places, Trips])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? openConnection());

  /// File name (native) / storage name (web) of the production database.
  static const defaultName = 'commute_planner';

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // Schema history lives in drift_schemas/ (dart run drift_dev make-migrations).
          // When bumping schemaVersion, add a step here, e.g.
          //   await m.runMigrationSteps(from: from, to: to, steps: migrationSteps(from1To2: ...));
          // and regenerate the migration tests in test/drift/.
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          // Let the background (workmanager) engine and the UI engine share the
          // file: WAL allows a reader during writes, busy_timeout waits on locks.
          // Both are no-ops for in-memory test databases.
          await customStatement('PRAGMA busy_timeout = 5000');
          if (!kIsWeb) await customSelect('PRAGMA journal_mode = WAL').get();
        },
      );

  /// Opens the on-device database.
  ///
  /// * Android/iOS/desktop: SQLite file in the app documents dir. WAL mode +
  ///   busy timeout let the workmanager background engine and the UI engine
  ///   use the same file safely; `shareAcrossIsolates` shares one connection
  ///   between isolates of the same engine.
  /// * Web: SQLite compiled to WebAssembly (web/sqlite3.wasm) persisted in
  ///   OPFS or IndexedDB, driven by web/drift_worker.js.
  static QueryExecutor openConnection({String name = defaultName}) => driftDatabase(
        name: name,
        native: const DriftNativeOptions(shareAcrossIsolates: true),
        web: DriftWebOptions(
          sqlite3Wasm: Uri.parse('sqlite3.wasm'),
          driftWorker: Uri.parse('drift_worker.js'),
        ),
      );
}
