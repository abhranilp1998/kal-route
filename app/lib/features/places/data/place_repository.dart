import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import 'place.dart';

class PlaceRepository {
  PlaceRepository(this._db);
  final AppDatabase _db;

  static Place _toDomain(PlaceRow r) =>
      Place(id: r.id, name: r.name, lat: r.lat, lng: r.lng, address: r.address, emoji: r.emoji);

  PlacesCompanion _toCompanion(Place p) => PlacesCompanion(
    id: p.id == 0 ? const Value.absent() : Value(p.id),
    name: Value(p.name),
    lat: Value(p.lat),
    lng: Value(p.lng),
    address: Value(p.address),
    emoji: Value(p.emoji),
  );

  SimpleSelectStatement<$PlacesTable, PlaceRow> _ordered() =>
      _db.select(_db.places)..orderBy([(t) => OrderingTerm.asc(t.id)]);

  Future<List<Place>> all() async => (await _ordered().get()).map(_toDomain).toList();
  Stream<List<Place>> watchAll() => _ordered().watch().map((rows) => rows.map(_toDomain).toList());

  Future<Place?> byId(int id) async {
    final row = await (_db.select(_db.places)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  /// Inserts (id == 0) or updates; returns the saved place with its id.
  Future<Place> save(Place p) async {
    if (p.id == 0) {
      final id = await _db.into(_db.places).insert(_toCompanion(p));
      return p.copyWith(id: id);
    }
    await _db.into(_db.places).insertOnConflictUpdate(_toCompanion(p));
    return p;
  }

  /// Deleting a place also deletes its trips (ON DELETE CASCADE).
  Future<void> delete(int id) => (_db.delete(_db.places)..where((t) => t.id.equals(id))).go();
}
