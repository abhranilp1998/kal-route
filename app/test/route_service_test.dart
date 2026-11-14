import 'package:commute_planner/core/api/mock_directions_client.dart';
import 'package:commute_planner/core/notifications/nightly_job.dart';
import 'package:commute_planner/features/route/data/route_result.dart';
import 'package:commute_planner/features/route/data/route_service.dart';
import 'package:commute_planner/features/settings/data/prefs.dart';
import 'package:flutter_test/flutter_test.dart';

RouteResult r(int minutes, int fare, List<String> modes, {int walk = 5}) {
  final start = DateTime(2026, 11, 16, 9);
  final legs = [for (final m in modes) RouteLeg(m, null, 'a', 'b', m == 'WALK' ? walk : 10, m == 'WALK' ? 0 : null)];
  return RouteResult(legs, start, start.add(Duration(minutes: minutes)), totalFareInr: fare);
}

void main() {
  final fast = r(40, 35, ['WALK', 'METRO', 'BUS', 'WALK'], walk: 6);
  final cheap = r(60, 20, ['WALK', 'BUS', 'WALK']);
  final walky = r(35, 15, ['WALK', 'METRO', 'WALK'], walk: 12);

  test('fastest picks the shortest trip', () {
    expect(pickBest([fast, cheap, walky], Prefs()), walky);
  });

  test('cheapest picks the lowest fare', () {
    expect(pickBest([fast, cheap], Prefs(priority: 'cheapest')), cheap);
  });

  test('least_changes picks the fewest transit legs', () {
    expect(pickBest([fast, cheap], Prefs(priority: 'least_changes')), cheap);
  });

  test('avoidLongWalks drops routes with more than 15 walking minutes', () {
    // walky has 24 min of walking in total (2 x 12)
    expect(pickBest([fast, walky], Prefs(avoidLongWalks: true)), fast);
  });

  test('avoidLongWalks falls back when every route is walky', () {
    expect(pickBest([walky], Prefs(avoidLongWalks: true)), walky);
  });

  test('leaveTime subtracts the buffer', () {
    expect(leaveTime(fast, Prefs(bufferMinutes: 5)), DateTime(2026, 11, 16, 8, 55));
  });

  test('nextRunAt rolls over to tomorrow once 9 PM has passed', () {
    expect(nextRunAt(21, 0, DateTime(2026, 11, 14, 19, 30)), DateTime(2026, 11, 14, 21));
    expect(nextRunAt(21, 0, DateTime(2026, 11, 14, 21, 5)), DateTime(2026, 11, 15, 21));
  });

  test('mock client returns Kolkata example routes that arrive before arriveBy', () async {
    const mock = MockDirectionsClient(latency: Duration.zero);
    final arrive = DateTime(2026, 11, 16, 10);
    final routes = await mock.transitRoutes(
      fromLat: 0,
      fromLng: 0,
      toLat: 0,
      toLng: 0,
      arriveBy: arrive,
      fromName: 'Home',
      toName: 'College',
    );
    expect(routes, isNotEmpty);
    expect(routes.first.legs.any((l) => l.line == 'Blue Line'), isTrue);
    expect(routes.first.fare, 35);
    for (final rt in routes) {
      expect(rt.arriveAt.isAfter(arrive), isFalse);
    }
    // Reverse direction works too.
    final back = await mock.transitRoutes(
      fromLat: 0,
      fromLng: 0,
      toLat: 0,
      toLng: 0,
      arriveBy: arrive,
      fromName: 'College',
      toName: 'Home',
    );
    expect(back.first.legs.first.from, 'College');
  });
}
