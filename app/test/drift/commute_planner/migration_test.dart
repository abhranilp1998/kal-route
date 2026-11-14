// Schema/migration safety net (drift_dev schema tooling).
//
// drift_schemas/commute_planner/drift_schema_vN.json snapshots every released
// schema. When schemaVersion is bumped: run
//   dart run drift_dev make-migrations
// which snapshots the new version, regenerates `generated/`, and this test then
// checks every upgrade path (vN -> latest) produces exactly the expected schema.
import 'package:commute_planner/core/db/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('current schema matches the latest snapshot', () async {
    final schema = await verifier.schemaAt(1);
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 1);
    await db.close();
  });

  test('every snapshot version upgrades to the current schema', () async {
    for (final from in GeneratedHelper.versions) {
      final schema = await verifier.schemaAt(from);
      final db = AppDatabase(schema.newConnection());
      await verifier.migrateAndValidate(db, db.schemaVersion);
      await db.close();
    }
  });
}
