// End-to-end flow on a real app instance (real drift database, real map
// picker with OpenStreetMap tiles + live Nominatim search/reverse geocoding,
// real router and widgets). Only the route source is the example client,
// because no Google key is configured on the test machine.
//
// Web:     see README "Integration test" (chromedriver + flutter drive)
// Android: flutter test integration_test -d <device>
import 'package:commute_planner/core/db/app_database.dart';
import 'package:commute_planner/core/utils/time_utils.dart';
import 'package:commute_planner/features/places/data/place_repository.dart';
import 'package:commute_planner/features/plan/data/plan_repository.dart';
import 'package:commute_planner/features/plan/data/trip.dart';
import 'package:commute_planner/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 40),
  String? reason,
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Timed out waiting for ${reason ?? finder}');
}

/// Scrolls [finder] into view (sheets and lists overflow on 320x640 phones)
/// before tapping it, like a user would.
Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(finder);
}

Future<void> pumpFor(WidgetTester tester, Duration d) async {
  final end = DateTime.now().add(d);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('map picker → add place → add trip → route detail → nightly job updates DB', (tester) async {
    // Route keyboard input through the test text input (needed on web).
    binding.testTextInput.register();
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase(AppDatabase.openConnection(name: 'it_${DateTime.now().millisecondsSinceEpoch}'));
    addTearDown(db.close);
    final places = PlaceRepository(db);
    final plans = PlanRepository(db);

    await tester.pumpWidget(await bootstrap(db: db, background: false));
    await pumpUntil(tester, find.text('Add trip'), reason: 'Tomorrow screen');
    expect(await places.all(), hasLength(4), reason: 'example places seeded');

    // ---- Places → Add place → map picker -----------------------------------
    await tapVisible(tester, find.descendant(of: find.byType(NavigationBar), matching: find.text('Places')));
    await pumpUntil(tester, find.text('Add place'));
    await tapVisible(tester, find.text('Add place'));
    await pumpUntil(tester, find.byKey(const Key('place-name')));
    await tester.enterText(find.byKey(const Key('place-name')), 'Office');
    await tapVisible(tester, find.byKey(const Key('pick-on-map')));
    await pumpUntil(tester, find.byKey(const Key('map-search')), reason: 'map picker');

    // Search (live Nominatim) and pick the first hit.
    await tester.enterText(find.byKey(const Key('map-search')), 'Park Street, Kolkata');
    await tapVisible(tester, find.byKey(const Key('map-search-go')));
    await pumpUntil(tester, find.byKey(const Key('search-result-0')), reason: 'search results');
    await tapVisible(tester, find.byKey(const Key('search-result-0')));
    await pumpFor(tester, const Duration(milliseconds: 500));

    // Drop the pin a little away from the search hit by tapping the map.
    final mapCenter = tester.getCenter(find.byKey(const Key('map')));
    await tester.tapAt(mapCenter + const Offset(40, 60));
    // Wait for the debounced reverse geocode to fill the address.
    final addressText = find.byKey(const Key('picked-address'));
    final end = DateTime.now().add(const Duration(seconds: 40));
    String current() => (tester.widget<Text>(addressText).data ?? '');
    await pumpFor(tester, const Duration(seconds: 2));
    while (DateTime.now().isBefore(end) &&
        (current().startsWith('Looking up') || find.textContaining('updating').evaluate().isNotEmpty)) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    final pickedAddress = current();
    expect(pickedAddress, isNot(startsWith('Looking up')));
    expect(pickedAddress, isNot(contains('failed')), reason: 'reverse geocoding should work');
    await tapVisible(tester, find.byKey(const Key('use-location')));
    await pumpUntil(tester, find.byKey(const Key('save-place')));
    expect(find.text('Pin set'), findsOneWidget);
    await tapVisible(tester, find.byKey(const Key('save-place')));
    await pumpUntil(tester, find.text('Office'), reason: 'Office tile');

    final office = (await places.all()).singleWhere((p) => p.name == 'Office');
    expect(office.lat, closeTo(22.55, 0.05));
    expect(office.lng, closeTo(88.35, 0.05));
    expect(office.address, pickedAddress);

    // ---- Tomorrow → Add trip Home → Office ----------------------------------
    await tapVisible(tester, find.descendant(of: find.byType(NavigationBar), matching: find.text('Tomorrow')));
    await pumpUntil(tester, find.text('Add trip'));
    await tapVisible(tester, find.text('Add trip'));
    await pumpUntil(tester, find.text('Plan a trip'));
    await tapVisible(tester, find.text('Office').last); // "To" row
    await pumpUntil(tester, find.textContaining('Leave time includes'), reason: 'route preview');
    await tapVisible(tester, find.text('Plan it'));
    await pumpFor(tester, const Duration(seconds: 1));

    final tomorrow = await plans.tripsOn(tomorrowDate());
    final trip = tomorrow.singleWhere((t) => t.toPlaceId == office.id);
    expect(trip.leaveAt, isNotNull, reason: 'route planned and saved');
    expect(trip.cachedRouteJson, isNotNull);
    expect(trip.bufferMinutes, 5);
    expect(trip.status, TripStatus.planned);

    // ---- Route detail --------------------------------------------------------
    await pumpUntil(tester, find.text('Office'));
    await tapVisible(tester, find.text('Office').first);
    await pumpUntil(tester, find.text('Leave Home'), reason: 'route detail timeline');
    expect(find.text('☕ Buffer'), findsOneWidget);
    expect(find.text('Set off'), findsOneWidget);
    expect(find.text(fmtTime(trip.leaveAt!)), findsWidgets, reason: 'timeline starts at the card leave time');
    await tapVisible(tester, find.byTooltip('Back'));
    // The list may be scrolled (ensureVisible above), so wait for the always-visible FAB.
    await pumpUntil(tester, find.text('Add trip'), reason: 'back on Tomorrow');

    // ---- Settings → Run nightly job now -> DB updated -------------------------
    await tapVisible(tester, find.descendant(of: find.byType(NavigationBar), matching: find.text('Settings')));
    await pumpUntil(tester, find.text('Settings').last);
    // Below the fold on short screens: scroll the settings list like a user would.
    await tester.scrollUntilVisible(find.text('Run nightly job now'), 200, scrollable: find.byType(Scrollable).first);
    await tapVisible(tester, find.text('Run nightly job now'));
    await pumpUntil(tester, find.textContaining('3 trips tomorrow'), reason: 'nightly result');

    final after = await plans.tripsOn(tomorrowDate());
    expect(after, hasLength(3));
    expect(after.every((t) => t.status == TripStatus.notified), isTrue);
    expect(after.every((t) => t.leaveAt != null && t.routeFetchedAt != null), isTrue);
  });
}
