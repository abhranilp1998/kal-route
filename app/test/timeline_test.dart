import 'package:commute_planner/features/route/data/route_result.dart';
import 'package:commute_planner/features/route/data/timeline.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final d = DateTime(2026, 11, 16);
  DateTime at(int h, int m) => DateTime(d.year, d.month, d.day, h, m);
  final route = RouteResult(
    [
      const RouteLeg('WALK', null, 'Home', 'Kalighat Metro', 6, 0),
      RouteLeg(
        'METRO',
        'Blue Line',
        'Kalighat Metro',
        'Esplanade',
        14,
        15,
        stops: 6,
        headsign: 'Dakshineswar',
        departAt: DateTime(2026, 11, 16, 9, 18),
      ),
      const RouteLeg('BUS', 'S-12', 'Esplanade', 'Karunamoyee', 18, 20, headsign: 'Salt Lake'),
      const RouteLeg('WALK', null, 'Karunamoyee', 'College', 5, 0),
    ],
    at(9, 12),
    at(9, 55),
  );

  test('starts at the leave time and shows the buffer as its own segment', () {
    final t = buildTimeline(
      route: route,
      leaveAt: at(9, 7),
      bufferMinutes: 5,
      startName: 'Home',
      endName: 'College',
      arriveBy: at(10, 0),
    );
    expect(t.nodes.first.kind, NodeKind.leave);
    expect(t.nodes.first.time, at(9, 7)); // == card + notification leave time
    expect(t.nodes.first.title, 'Leave Home');
    expect(t.segments.first.isBuffer, isTrue);
    expect(t.segments.first.minutes, 5);
    expect(t.nodes[1].kind, NodeKind.setOff);
    expect(t.nodes[1].time, at(9, 12));
    expect(t.nodes[1].subtitle, 'walk to Kalighat Metro');
    expect(t.nodes.map((n) => n.title).skip(2), ['Kalighat Metro', 'Esplanade', 'Karunamoyee', 'College']);
    expect(t.nodes.map((n) => n.time).skip(2), [at(9, 18), at(9, 32), at(9, 50), at(9, 55)]);
    expect(t.nodes.last.subtitle, '5 min before 10:00');
    expect(t.nodes.length, t.segments.length + 1);
  });

  test('without a buffer the first node is the route departure', () {
    final t = buildTimeline(route: route, leaveAt: at(9, 12), bufferMinutes: 0, startName: 'Home', endName: 'College');
    expect(t.segments.any((s) => s.isBuffer), isFalse);
    expect(t.nodes.first.time, at(9, 12));
    expect(t.nodes.first.mode, 'WALK');
    expect(t.nodes.length, route.legs.length + 1);
  });

  test('waits for a transit departure later than the walk arrival', () {
    final r = RouteResult(
      [
        const RouteLeg('WALK', null, 'Home', 'Stop', 4, 0),
        RouteLeg('BUS', '215A', 'Stop', 'Karunamoyee', 30, 20, departAt: at(9, 10)),
      ],
      at(9, 0),
      at(9, 40),
    );
    final t = buildTimeline(route: r, leaveAt: null, bufferMinutes: 0, startName: 'Home', endName: 'College');
    expect(t.nodes[1].time, at(9, 4)); // reach stop
    expect(t.nodes.last.time, at(9, 40));
  });
}
