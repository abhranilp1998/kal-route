import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import 'trip.dart';

class PlanRepository {
  PlanRepository(this._db);
  final AppDatabase _db;

  static Trip _toDomain(TripRow r) => Trip(
    id: r.id,
    date: r.date,
    fromPlaceId: r.fromPlaceId,
    toPlaceId: r.toPlaceId,
    arriveBy: r.arriveBy,
    status: r.status,
    leaveAt: r.leaveAt,
    bufferMinutes: r.bufferMinutes,
    cachedRouteJson: r.routeJson,
    routeFetchedAt: r.routeFetchedAt,
    routeSource: r.routeSource,
  );

  TripsCompanion _toCompanion(Trip t) => TripsCompanion(
    id: t.id == 0 ? const Value.absent() : Value(t.id),
    date: Value(DateTime(t.date.year, t.date.month, t.date.day)),
    fromPlaceId: Value(t.fromPlaceId),
    toPlaceId: Value(t.toPlaceId),
    arriveBy: Value(t.arriveBy),
    status: Value(t.status),
    leaveAt: Value(t.leaveAt),
    bufferMinutes: Value(t.bufferMinutes),
    routeJson: Value(t.cachedRouteJson),
    routeFetchedAt: Value(t.routeFetchedAt),
    routeSource: Value(t.routeSource),
  );

  SimpleSelectStatement<$TripsTable, TripRow> _onDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    // Uses trips_date_idx.
    return _db.select(_db.trips)
      ..where((t) => t.date.isBiggerOrEqualValue(start) & t.date.isSmallerThanValue(end))
      ..orderBy([(t) => OrderingTerm.asc(t.arriveBy)]);
  }

  Future<List<Trip>> all() async => (await _db.select(_db.trips).get()).map(_toDomain).toList();
  Future<List<Trip>> tripsOn(DateTime day) async => (await _onDay(day).get()).map(_toDomain).toList();
  Stream<List<Trip>> watchTripsOn(DateTime day) => _onDay(day).watch().map((rows) => rows.map(_toDomain).toList());
  Stream<List<Trip>> watchAll() => _db.select(_db.trips).watch().map((r) => r.map(_toDomain).toList());

  Future<Trip?> byId(int id) async {
    final row = await (_db.select(_db.trips)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  Stream<Trip?> watchById(int id) => (_db.select(
    _db.trips,
  )..where((t) => t.id.equals(id))).watchSingleOrNull().map((r) => r == null ? null : _toDomain(r));

  Future<Trip> save(Trip t) async {
    if (t.id == 0) {
      t.id = await _db.into(_db.trips).insert(_toCompanion(t));
      return t;
    }
    await _db.into(_db.trips).insertOnConflictUpdate(_toCompanion(t));
    return t;
  }

  Future<void> delete(int id) => (_db.delete(_db.trips)..where((t) => t.id.equals(id))).go();
}
