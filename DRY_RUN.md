# Dry run: Commute Planner v1.1

Run on the box on Sat 14 Nov 2026, 20:05–21:40 IST. Flutter 3.47.7 stable, Dart 3.14.0, JDK 17,
Android SDK 36/37, Chrome 156.

| # | Item | Result | Evidence / notes |
|---|------|--------|------------------|
| 1 | Clean checkout: copy without build/, .dart_tool, generated `*.g.dart`; `flutter clean`; `flutter pub get` | PASS | done in /tmp/cleancheck |
| 2 | Code generation (`dart run build_runner build`, drift) | PASS | 82 outputs, no warnings |
| 3 | `flutter analyze` (clean checkout + working tree) | PASS | "No issues found!" |
| 4 | `flutter test` (unit, DB, migration) | PASS | 34/34: Directions parsing 6, route picking/scheduling/mock 8, timeline 3, Nominatim parsing/throttle/cache 4, DB repositories + legacy import + seed + nightly 11, drift schema/migration 2 |
| 5 | Drift schema snapshot + migration verifier | PASS | `drift_schemas/commute_planner/drift_schema_v1.json`, `test/drift/commute_planner/migration_test.dart` |
| 6 | Integration test on web (headless Chrome): map picker (live OSM tiles, Nominatim search + reverse geocoding) → add place → add trip → plan route → route detail (Leave/Buffer/Set off) → run nightly job → DB checked | PASS | `integration_test/app_flow_test.dart`, run as a web bundle with `tools/run_it_web.js`: "All tests passed!" (11 s) |
| 7 | Same integration test with the official `flutter drive -d web-server` + chromedriver | NOT VERIFIED | started Chrome, then printed nothing for 700 s. The identical test bundle passes under the playwright runner (item 6). Not debugged further, to save time |
| 8 | `flutter build web --release` | PASS | served from app/build/web; uses web/sqlite3.wasm + web/drift_worker.js (IndexedDB storage in headless Chrome) |
| 9 | Screenshots of all screens incl. map picker | PASS | screenshots/01–08 + 00_overview.png |
| 10 | `flutter build apk --debug` | PASS | copied to commute_planner-debug.apk |
| 11 | Build warnings | PARTIAL | KGP warning: `android.builtInKotlin=true` means workmanager_android does not apply KGP when it builds. But Flutter's static text scan still prints the warning, because the plugin's build.gradle contains a conditional `apply plugin: 'kotlin-android'`, and no newer plugin version exists. geolocator_android prints a javac deprecation note from its own Java code. No warnings from app code |
| 12 | Android emulator boot | PASS (slow) | /dev/kvm is `root:pulse-access 0660` and the box user is not in that group, so there is no hardware acceleration. Software emulation (`-accel off -gpu swiftshader_indirect -no-snapshot -no-window`, 3 GB RAM, 2 cores) boots in about 2–10 min |
| 13 | APK install on emulator | PASS (3rd attempt) | attempts 1–2: the emulator's hang watchdog killed it during `adb install`; attempt 3: `Success` |
| 14 | App launch on emulator | PARTIAL | the process starts, the Flutter engine starts (Impeller, Dart VM service up), MainActivity is topResumed, and logcat shows no Dart or Java exceptions. Rendering couldn't be checked visually: Android's own "System UI isn't responding" and service-timeout dialogs cover the screen because of software emulation |
| 15 | Integration test on Android emulator | NOT FEASIBLE | same reason as 12–14: without KVM the emulator is too slow for a Flutter debug build plus a test driver (it already crashes or shows timeout dialogs on install and launch) |
| 16 | Background nightly job on a real device (workmanager → notification at 9 PM) | NOT VERIFIED | needs a real device or an accelerated emulator. The job's logic (`runNightlyPlan`) is covered by unit tests and the web integration test |
| 17 | Real Google Directions routes | NOT VERIFIED | no MAPS_KEY on the box. Response parsing is tested with a recorded-format fixture |
| 18 | README updated, project zipped | PASS | README.md, commute_planner.zip |
