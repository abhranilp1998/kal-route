import 'package:http/http.dart' as http;

import '../../../core/api/directions_client.dart';
import '../../../core/api/directions_source.dart';
import '../../../core/api/mock_directions_client.dart';
import '../../places/data/place.dart';
import '../../route/data/route_result.dart';
import '../../route/data/route_service.dart';
import '../../settings/data/prefs.dart';
import 'trip.dart';

const mapsKey = String.fromEnvironment('MAPS_KEY');

/// Google Directions when a key was passed with --dart-define=MAPS_KEY=...,
/// otherwise the offline Kolkata example-data client (clearly labelled in UI).
DirectionsSource directionsFromEnv({http.Client? httpClient}) =>
    mapsKey.isEmpty ? const MockDirectionsClient() : DirectionsClient(mapsKey, httpClient: httpClient);

/// Fetches routes for [trip], picks the best one and caches it on the trip
/// together with the buffer used, so leave time, card, timeline and
/// notification always agree. Returns null (keeping any old cache) if no
/// route came back.
Future<RouteResult?> planTrip(
  Trip trip, {
  required Place from,
  required Place to,
  required DirectionsSource client,
  required Prefs prefs,
  DateTime? now,
}) async {
  final routes = await client.transitRoutes(
    fromLat: from.lat,
    fromLng: from.lng,
    toLat: to.lat,
    toLng: to.lng,
    arriveBy: trip.arriveBy,
    fromName: from.name,
    toName: to.name,
  );
  if (routes.isEmpty) return null;
  final best = pickBest(routes, prefs);
  trip
    ..bufferMinutes = prefs.bufferMinutes
    ..leaveAt = leaveTime(best, prefs)
    ..cachedRouteJson = best.toJson()
    ..routeFetchedAt = now ?? DateTime.now()
    ..routeSource = client.isMock ? 'example' : 'google';
  return best;
}

RouteResult? cachedRoute(Trip t) => t.cachedRouteJson == null ? null : RouteResult.fromJson(t.cachedRouteJson!);
