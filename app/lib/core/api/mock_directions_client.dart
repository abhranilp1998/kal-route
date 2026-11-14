import '../../features/route/data/route_result.dart';
import 'directions_source.dart';

/// Offline stand-in for Google Directions, used when MAPS_KEY is empty.
///
/// EXAMPLE DATA: hand-written, plausible Kolkata routes (Blue/Green/Purple
/// Line metro, city buses, autos). Times are worked backwards from the
/// requested arrival like Google does; fares are typical, not official.
class MockDirectionsClient implements DirectionsSource {
  const MockDirectionsClient({this.latency = const Duration(milliseconds: 350)});
  final Duration latency;

  @override
  bool get isMock => true;

  // Templates: (mode, line, from, to, minutes, fare, stops, headsign)
  static const _routes = <String, List<List<_L>>>{
    'home>college': [
      [
        _L('WALK', null, 'Home', 'Kalighat Metro', 6, 0),
        _L('METRO', 'Blue Line', 'Kalighat Metro', 'Esplanade', 14, 15, 6, 'Dakshineswar'),
        _L('BUS', 'S-12', 'Esplanade', 'Karunamoyee', 18, 20, 11, 'Salt Lake'),
        _L('WALK', null, 'Karunamoyee', 'College', 5, 0),
      ],
      [
        _L('WALK', null, 'Home', 'Kalighat Metro', 6, 0),
        _L('METRO', 'Blue Line', 'Kalighat Metro', 'Esplanade', 14, 15, 6, 'Dakshineswar'),
        _L('WALK', null, 'Esplanade', 'Esplanade (Green Line)', 4, 0),
        _L('METRO', 'Green Line', 'Esplanade (Green Line)', 'Karunamoyee', 17, 20, 7, 'Salt Lake Sector V'),
        _L('WALK', null, 'Karunamoyee', 'College', 5, 0),
      ],
      [
        _L('WALK', null, 'Home', 'Hazra More', 4, 0),
        _L('BUS', '215A', 'Hazra More', 'Karunamoyee', 52, 20, 24, 'Karunamoyee'),
        _L('WALK', null, 'Karunamoyee', 'College', 5, 0),
      ],
    ],
    'college>gym': [
      [
        _L('BUS', 'DN-18', 'Karunamoyee', 'City Centre', 16, 15, 5, 'City Centre'),
        _L('WALK', null, 'City Centre', 'Gym', 6, 0),
      ],
      [
        _L('WALK', null, 'College', 'Karunamoyee Metro', 7, 0),
        _L('METRO', 'Green Line', 'Karunamoyee Metro', 'City Centre', 6, 10, 2, 'Howrah Maidan'),
        _L('WALK', null, 'City Centre', 'Gym', 7, 0),
      ],
    ],
    'home>gym': [
      [
        _L('WALK', null, 'Home', 'Kalighat Metro', 6, 0),
        _L('METRO', 'Blue Line', 'Kalighat Metro', 'Esplanade', 14, 15, 6, 'Dakshineswar'),
        _L('WALK', null, 'Esplanade', 'Esplanade (Green Line)', 4, 0),
        _L('METRO', 'Green Line', 'Esplanade (Green Line)', 'City Centre', 14, 20, 5, 'Salt Lake Sector V'),
        _L('WALK', null, 'City Centre', 'Gym', 6, 0),
      ],
    ],
    "home>mom's place": [
      [
        _L('WALK', null, 'Home', 'Kalighat', 3, 0),
        _L('AUTO', 'Kalighat–Behala', 'Kalighat', 'Behala Chowrasta', 24, 30, null, 'Behala'),
        _L('WALK', null, 'Behala Chowrasta', "Mom's place", 4, 0),
      ],
      [
        _L('WALK', null, 'Home', 'Hazra More', 5, 0),
        _L('BUS', '12C/1', 'Hazra More', 'Behala Chowrasta', 28, 15, 12, 'Thakurpukur'),
        _L('WALK', null, 'Behala Chowrasta', "Mom's place", 4, 0),
      ],
    ],
    "college>mom's place": [
      [
        _L('WALK', null, 'College', 'Karunamoyee Metro', 7, 0),
        _L('METRO', 'Green Line', 'Karunamoyee Metro', 'Esplanade (Green Line)', 17, 20, 7, 'Howrah Maidan'),
        _L('WALK', null, 'Esplanade (Green Line)', 'Esplanade', 4, 0),
        _L('METRO', 'Blue Line', 'Esplanade', 'Tollygunge', 18, 20, 8, 'Kavi Subhash'),
        _L('AUTO', 'Tolly–Behala', 'Tollygunge', 'Behala Chowrasta', 15, 25, null, 'Behala'),
        _L('WALK', null, 'Behala Chowrasta', "Mom's place", 4, 0),
      ],
    ],
  };

  @override
  Future<List<RouteResult>> transitRoutes({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
    required DateTime arriveBy,
    String? fromName,
    String? toName,
  }) async {
    await Future<void>.delayed(latency);
    final a = (fromName ?? 'Start').toLowerCase();
    final b = (toName ?? 'Destination').toLowerCase();
    var templates = _routes['$a>$b'];
    var reversed = false;
    if (templates == null && _routes['$b>$a'] != null) {
      templates = _routes['$b>$a'];
      reversed = true;
    }
    templates ??= _generic(fromName ?? 'Start', toName ?? 'Destination');

    final out = <RouteResult>[];
    for (var i = 0; i < templates.length; i++) {
      var legs = templates[i];
      if (reversed) {
        legs = legs.reversed.map((l) => l.flipped()).toList();
      }
      // Google returns routes arriving a little before the requested time.
      final arriveAt = arriveBy.subtract(Duration(minutes: 5 + i * 3));
      final total = legs.fold<int>(0, (s, l) => s + l.minutes);
      final leaveAt = arriveAt.subtract(Duration(minutes: total));
      var t = leaveAt;
      final built = <RouteLeg>[];
      for (final l in legs) {
        built.add(RouteLeg(l.mode, l.line, l.from, l.to,
            l.minutes, l.fare,
            stops: l.stops, headsign: l.headsign, departAt: t));
        t = t.add(Duration(minutes: l.minutes));
      }
      out.add(RouteResult(built, leaveAt, arriveAt));
    }
    return out;
  }

  List<List<_L>> _generic(String from, String to) => [
        [
          _L('WALK', null, from, 'Main road', 5, 0),
          _L('AUTO', 'Shared auto', 'Main road', 'Nearest stand', 18, 25, null, to),
          _L('WALK', null, 'Nearest stand', to, 4, 0),
        ],
        [
          _L('WALK', null, from, 'Bus stop', 6, 0),
          _L('BUS', 'S-9', 'Bus stop', 'Stop near $to', 30, 15, 14, to),
          _L('WALK', null, 'Stop near $to', to, 5, 0),
        ],
      ];
}

class _L {
  const _L(this.mode, this.line, this.from, this.to, this.minutes, this.fare, [this.stops, this.headsign]);
  final String mode;
  final String? line;
  final String from, to;
  final int minutes;
  final int fare;
  final int? stops;
  final String? headsign;

  _L flipped() => _L(mode, line, to, from, minutes, fare, stops, null);
}
