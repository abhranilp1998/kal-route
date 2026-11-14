# Commute Planner (v1.1)

[![CI](https://github.com/abhranilp1998/kal-route/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/abhranilp1998/kal-route/actions/workflows/ci.yml)
[![Release](https://github.com/abhranilp1998/kal-route/actions/workflows/release.yml/badge.svg)](https://github.com/abhranilp1998/kal-route/actions/workflows/release.yml)
[![Latest release](https://img.shields.io/github/v/release/abhranilp1998/kal-route)](https://github.com/abhranilp1998/kal-route/releases/latest)
[![Web demo](https://img.shields.io/badge/web-GitHub%20Pages-blue)](https://abhranilp1998.github.io/kal-route/)

Personal commute planner for Kolkata. Save your places on a map, add tomorrow's
trips, and every night the app fetches transit routes (metro, bus, auto, walk)
and sends one card: "2 trips tomorrow · First: leave Home at 9:07 for College (arrive 9:55)".

```
commute-app/
  mockups/       HTML/CSS design mockups + PNGs
  screenshots/   screenshots of the running web build (390x844 @2x), incl. map picker
  app/           Flutter project (package: commute_planner)
  tools/         playwright scripts (mockups, screenshots, web integration-test runner)
  DRY_RUN.md     end-to-end dry-run checklist with pass/fail
  commute_planner-debug.apk   debug APK (example route data, no key)
```

## Stack and why each dependency

| Need | Package (version) | Why |
|---|---|---|
| UI | Flutter 3.50.0 stable, Dart 3.14, `material_ui` | current stable; `material_ui` is the new home of Material widgets |
| State | `flutter_riverpod` 3.5 | stream providers over drift watch queries |
| Navigation | `go_router` 18.1 | bottom-bar shell + pushed route detail |
| **Database** | `drift` 2.35.4, `drift_flutter` 0.3.1, `drift_dev` + `build_runner` | see below |
| Prefs | `shared_preferences` 2.5 | only the small settings object (notify time, buffer, priority) |
| Routing data | Google Directions API via `http` 1.6 | real transit routes when `MAPS_KEY` is set |
| Map | `flutter_map` 8.3.2 + `latlong2` 0.10 + OpenStreetMap tiles | real map without an API key; works on Android and web |
| Geocoding | Nominatim (OSM) via `http` | address search + reverse geocoding without a key |
| Location | `geolocator` 14.1.2 | GPS on Android, browser Geolocation on web |
| Links | `url_launcher` 6 | OSM copyright attribution link (required by the tile policy) |
| Background | `workmanager` 0.10.10 | Android WorkManager one-off job, rescheduled nightly |
| Notifications | `flutter_local_notifications` 23.0.2 | the nightly card |

**Why Drift and not Isar Community.** `isar_community` 3.4.1 does work with
Dart 3.14, but Isar 3 has no production web backend, its migration story is
"schemaless, hope for the best", and it ships its own native core per ABI. Drift
is SQLite: proper schema, foreign keys with `ON DELETE CASCADE`, indexes
(`trips_date_idx`, `trips_status_idx`), versioned migrations with schema
snapshots and generated migration tests, the same engine on Android (native
SQLite) and web (SQLite compiled to WebAssembly, `web/sqlite3.wasm` +
`web/drift_worker.js`, persisted in IndexedDB/OPFS), and it is actively
released (2.35.4 shipped this month).

**Background isolate access.** The workmanager job runs in a separate Flutter
engine and opens the same SQLite file (`AppDatabase()`), with `WAL` journal mode
and `busy_timeout = 5000` so it can write while the UI holds a connection.
`shareAcrossIsolates: true` shares one connection between isolates of the same
engine. Because separate engines can't share drift's stream updates, the app
re-runs its watch queries when it returns to the foreground
(`AppLifecycleListener` → `markTablesUpdated`).

**Migrations.** `schemaVersion = 1`, snapshot in `drift_schemas/commute_planner/`.
When the schema changes: bump `schemaVersion`, add a step in
`MigrationStrategy.onUpgrade`, run `dart run drift_dev make-migrations`, and
`test/drift/commute_planner/migration_test.dart` verifies every upgrade path.
Data from the first build (JSON in shared_preferences) is imported once, in a
transaction, by `core/db/legacy_import.dart`.

## Map picker

Places → Add place → **Pick on map** opens a full-screen OpenStreetMap view:
- pan the map or tap anywhere to drop the pin (pin stays centred),
- search an address or landmark (Nominatim, on submit; biased to Kolkata, limited to India),
- "my location" button (geolocator),
- the pin is reverse-geocoded to fill the address, which you can still edit.

Nominatim usage policy is respected: requests are serialised and spaced at
least 1.1 s apart, results are cached, there is no search-as-you-type, and
Android sends a `User-Agent` identifying the app (browsers don't allow setting
User-Agent, so on web the browser's own UA and Referer identify it). OSM tiles
use `userAgentPackageName` and show the required attribution.

## Leave time, buffer and timeline

The leave time is stored on the trip together with the buffer used to compute
it (`leaveAt = route departure − buffer`). The card shows "9:07 LEAVE · incl. 5 min
buffer"; the route timeline starts with **Leave Home 9:07**, a **☕ Buffer 5 min**
segment, **Set off 9:12**, then each leg; the notification says "leave Home at 9:07".

## Routes: Google or example data

`--dart-define=MAPS_KEY=...` uses the Google Directions API (transit). Without a
key the app uses `MockDirectionsClient`: hand-written, plausible Kolkata routes,
labelled "Example Kolkata routes" in the app and "EXAMPLE ROUTE DATA" on the
timeline. Trips record which source planned them (`routeSource`).

## Run

```bash
cd app
flutter pub get
dart run build_runner build        # drift code generation

flutter run -d chrome                                   # web
flutter run --dart-define=MAPS_KEY=YOUR_KEY             # Android, real routes
flutter build apk --debug --dart-define=MAPS_KEY=YOUR_KEY
flutter build web && (cd build/web && python3 -m http.server 8099)
```

Android notes: `compileSdk = 37` (needed by flutter_local_notifications 23 and
androidx.core 1.19), core library desugaring on, and the manifest declares
`POST_NOTIFICATIONS`, `INTERNET` and location permissions.
`android.builtInKotlin=true` (AGP 9 built-in Kotlin) so no plugin applies the
legacy Kotlin Gradle Plugin. See "Known limitations" about the remaining warning text.

## Tests

```bash
flutter analyze
flutter test                     # unit + DB + migration tests
```

Integration test (`integration_test/app_flow_test.dart`) drives the real app:
map picker (live OSM + Nominatim) → add place → add trip → route detail → run
nightly job → checks the database.

```bash
# Web, headless Chrome: build the test as a web app and run it with the playwright runner
flutter build web -t integration_test/app_flow_test.dart --profile -o /tmp/itweb
(cd /tmp/itweb && python3 -m http.server 8111) &
node ../tools/run_it_web.js 8111      # prints the test log; needs tools/node_modules (npm i playwright-core)

# Official driver (needs chromedriver matching Chrome on :4444)
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/app_flow_test.dart -d web-server --browser-name=chrome --headless

# Android device/emulator
flutter test integration_test -d <device-id>
```

## Web vs Android

Everything runs on web except background work: there is no scheduled nightly
job and no system notification on web. Settings says so; "Run nightly job now"
runs the same planning code, saves the routes to the database and shows the
card text in-app.

## CI/CD

All workflows pin Flutter **3.50.0** (stable, Dart 3.14) and every action by commit SHA. Dependabot
(`.github/dependabot.yml`) opens weekly PRs for pub, Gradle and GitHub Actions, monthly for the
`tools/` npm package.

**CI** (`.github/workflows/ci.yml`, on push/PR to `main`; older runs on the same ref are cancelled):

| Job | What it does |
|---|---|
| Codegen, format, analyze, unit tests | `pub get --enforce-lockfile`; reruns `build_runner` and fails if generated Drift code differs from what's committed; `dart format` check on hand-written code (page width 120, see `analysis_options.yaml`); `flutter analyze`; `flutter test --coverage` (lcov uploaded as `coverage-lcov`) |
| Web integration test + web build | Builds `integration_test/app_flow_test.dart` as a web app, runs it in headless Chrome at 320x640 and 390x844 with `tools/run_it_web.js` (exits non-zero unless the log says "All tests passed!"), then `flutter build web` (artifact `web-build`) |
| Android debug APK | `flutter build apk --debug` (artifact `app-debug-apk`) |
| Android emulator integration test | KVM-enabled API 34 x86_64 emulator via `reactivecircus/android-emulator-runner`, runs `flutter test integration_test/app_flow_test.dart` |

The integration test talks to live OpenStreetMap/Nominatim, so a rare red run can be a network
blip; re-run before digging in.

**Release** (`.github/workflows/release.yml`, on tags `v*`, e.g. `git tag v1.2.0 && git push origin v1.2.0`):

1. Derives `versionName` = `1.2.0` and `versionCode` = `major*10000 + minor*100 + patch` (`10200`) from the tag.
2. Restores the upload keystore from secrets and builds a **signed** release APK and AAB
   (`KAL_ROUTE_REQUIRE_RELEASE_SIGNING=true` makes the build fail rather than fall back to the debug key),
   then checks the signer and version with `apksigner`/`aapt2`.
3. Creates the GitHub Release with generated notes and attaches `kal-route-vX.Y.Z.apk`, `.aab` and `SHA256SUMS.txt`.
4. Builds the web app with `--base-href /kal-route/` and deploys it to GitHub Pages:
   <https://abhranilp1998.github.io/kal-route/>.

Repository secrets used by the release workflow:

| Secret | Purpose |
|---|---|
| `KAL_UPLOAD_KEYSTORE_BASE64` | base64 of the upload keystore (`.jks`, PKCS12) |
| `KAL_UPLOAD_STORE_PASSWORD` | keystore password |
| `KAL_UPLOAD_KEY_ALIAS` | key alias |
| `KAL_UPLOAD_KEY_PASSWORD` | key password |
| `MAPS_KEY` *(optional, not set)* | Google Directions key passed as `--dart-define=MAPS_KEY=...`; without it the app uses keyless routing |

**Signing locally.** `android/app/build.gradle.kts` reads signing values from the environment
(`KAL_ROUTE_KEYSTORE_PATH`, `KAL_ROUTE_KEYSTORE_PASSWORD`, `KAL_ROUTE_KEY_ALIAS`, `KAL_ROUTE_KEY_PASSWORD`)
or from a git-ignored `app/android/key.properties`:

```properties
storeFile=/absolute/path/to/kal-route-upload.jks
storePassword=...
keyAlias=upload
keyPassword=...
```

With neither present, release builds are signed with the debug key so `flutter run --release` still
works. Gradle must run on JDK 21 (AGP 9 lint needs it); the app bytecode still targets Java 17.

## Known limitations

- Without `MAPS_KEY` routes are example data (labelled). Google transit coverage
  for Kolkata buses is patchy; walk-only results show an "auto or cab" hint.
- Flutter 3.47 still prints "plugins that apply Kotlin Gradle Plugin (KGP):
  workmanager_android". That is a static text scan of the plugin's build.gradle:
  the plugin only applies KGP when `android.builtInKotlin=false`; this app sets it
  to `true`, so KGP is not applied at build time. No released or upstream
  version of workmanager_android removes the line yet (0.10.9 is latest).
- geolocator_android emits a javac "uses a deprecated API" note from its own
  Java sources (third-party, not our code).
- Live trip guidance ("Start trip") is planned for v2.
