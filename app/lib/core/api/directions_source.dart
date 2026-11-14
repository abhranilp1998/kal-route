import '../../features/route/data/route_result.dart';

/// Anything that can return transit routes. Implemented by the real Google
/// [DirectionsClient] and by [MockDirectionsClient] (used when no MAPS_KEY).
abstract class DirectionsSource {
  bool get isMock;

  Future<List<RouteResult>> transitRoutes({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
    required DateTime arriveBy,
    String? fromName,
    String? toName,
  });
}
