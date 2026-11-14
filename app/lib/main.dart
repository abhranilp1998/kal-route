import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'app/providers.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'core/db/app_database.dart';
import 'core/db/legacy_import.dart';
import 'core/db/seed.dart';
import 'core/notifications/nightly_job.dart';
import 'core/notifications/notification_service.dart';
import 'features/plan/data/trip_planner.dart';
import 'features/settings/data/prefs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(await bootstrap());
}

/// Opens the database, migrates legacy data, seeds example data on first
/// launch, sets up background work, and returns the root widget.
/// Integration tests call this with their own [db].
Future<Widget> bootstrap({AppDatabase? db, bool seed = true, bool background = true}) async {
  final database = db ?? AppDatabase();
  final sp = await SharedPreferences.getInstance();
  final prefs = await PrefsStore.load();
  await importLegacyPrefsData(database, sp);
  if (seed) await seedIfNeeded(database, directionsFromEnv(), prefs, sp: sp);

  if (background && !kIsWeb) {
    await Workmanager().initialize(callbackDispatcher);
    await NotificationService.init((payload) {
      if (payload == 'tomorrow') router.go('/tomorrow');
    });
    await scheduleNextRun(prefs.notifyHour, prefs.notifyMinute);
  }

  return ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(database),
      initialPrefsProvider.overrideWithValue(prefs),
    ],
    child: App(db: database),
  );
}

class App extends StatefulWidget {
  const App({super.key, required this.db});
  final AppDatabase db;
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // The nightly job runs in a separate Flutter engine and writes the same
    // SQLite file; on resume, re-run watch queries so the UI shows its writes.
    _lifecycle = AppLifecycleListener(
      onResume: () => widget.db.markTablesUpdated([widget.db.trips, widget.db.places]),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Commute Planner',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        darkTheme: buildTheme(),
        themeMode: ThemeMode.dark,
        routerConfig: router,
      );
}
