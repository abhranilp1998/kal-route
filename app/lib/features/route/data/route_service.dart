import '../../settings/data/prefs.dart';
import 'route_result.dart';

/// Picks the best route for the user's preferences.
RouteResult pickBest(List<RouteResult> routes, Prefs p) {
  if (routes.isEmpty) throw ArgumentError('no routes');
  var pool = p.avoidLongWalks ? routes.where((r) => r.walkMinutes <= 15).toList() : [...routes];
  if (pool.isEmpty) pool = [...routes];

  pool.sort((a, b) {
    final primary = switch (p.priority) {
      'cheapest' => a.fare.compareTo(b.fare),
      'least_changes' => a.transitLegs.compareTo(b.transitLegs),
      _ => a.totalMinutes.compareTo(b.totalMinutes),
    };
    return primary != 0 ? primary : a.totalMinutes.compareTo(b.totalMinutes);
  });
  return pool.first;
}

/// When to actually walk out of the door: route departure minus buffer.
DateTime leaveTime(RouteResult r, Prefs p) => r.leaveAt.subtract(Duration(minutes: p.bufferMinutes));
