import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../features/route/data/route_result.dart';
import 'directions_source.dart';

/// Google Directions API (transit mode). Pass the key with
/// `--dart-define=MAPS_KEY=...`.
class DirectionsClient implements DirectionsSource {
  DirectionsClient(this._apiKey, {http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final String _apiKey;
  final http.Client _http;

  @override
  bool get isMock => false;

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
    final uri = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
      'origin': '$fromLat,$fromLng',
      'destination': '$toLat,$toLng',
      'mode': 'transit',
      'arrival_time': '${arriveBy.millisecondsSinceEpoch ~/ 1000}',
      'alternatives': 'true',
      'region': 'in',
      'key': _apiKey,
    });
    final res = await _http.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw DirectionsException('HTTP_${res.statusCode}', res.reasonPhrase);
    }
    return parseDirectionsResponse(jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>);
  }
}

/// Parses a Directions API JSON body. Kept top-level so it is unit-testable.
List<RouteResult> parseDirectionsResponse(Map<String, dynamic> data) {
  final status = data['status'];
  if (status == 'ZERO_RESULTS') return [];
  if (status != 'OK') {
    throw DirectionsException(status as String? ?? 'UNKNOWN', data['error_message'] as String?);
  }
  return (data['routes'] as List).map((r) => _parseRoute(r as Map<String, dynamic>)).toList();
}

RouteResult _parseRoute(Map<String, dynamic> route) {
  final leg = (route['legs'] as List).first as Map<String, dynamic>;
  final steps = leg['steps'] as List;

  final legs = steps.map<RouteLeg>((raw) {
    final s = raw as Map<String, dynamic>;
    final mins = ((s['duration']['value'] as int) / 60).ceil();
    if (s['travel_mode'] == 'TRANSIT') {
      final t = s['transit_details'] as Map<String, dynamic>;
      final line = t['line'] as Map<String, dynamic>;
      final dep = t['departure_time']?['value'];
      return RouteLeg(
        mapVehicleType(line['vehicle']['type'] as String),
        (line['short_name'] ?? line['name']) as String?,
        t['departure_stop']['name'] as String,
        t['arrival_stop']['name'] as String,
        mins,
        null,
        stops: t['num_stops'] as int?,
        headsign: t['headsign'] as String?,
        departAt: dep is int ? DateTime.fromMillisecondsSinceEpoch(dep * 1000) : null,
      );
    }
    return RouteLeg('WALK', null, '', '', mins, 0);
  }).toList();

  // Name walking legs after neighbouring stops for a readable timeline.
  for (var i = 0; i < legs.length; i++) {
    final l = legs[i];
    if (!l.isWalk) continue;
    final from = i == 0 ? (leg['start_address'] as String? ?? 'Start') : legs[i - 1].to;
    final to = i == legs.length - 1 ? (leg['end_address'] as String? ?? 'End') : legs[i + 1].from;
    legs[i] = RouteLeg('WALK', null, from, to, l.minutes, 0);
  }

  final leaveAt = leg['departure_time'] != null
      ? DateTime.fromMillisecondsSinceEpoch((leg['departure_time']['value'] as int) * 1000)
      : DateTime.now();
  final arriveAt = leg['arrival_time'] != null
      ? DateTime.fromMillisecondsSinceEpoch((leg['arrival_time']['value'] as int) * 1000)
      : leaveAt.add(Duration(seconds: leg['duration']['value'] as int));

  final fare = route['fare']?['value'];
  return RouteResult(legs, leaveAt, arriveAt, totalFareInr: fare is num ? fare.round() : null);
}

String mapVehicleType(String vehicleType) => switch (vehicleType) {
      'SUBWAY' || 'METRO_RAIL' || 'HEAVY_RAIL' => 'METRO',
      'BUS' || 'INTERCITY_BUS' || 'TROLLEYBUS' => 'BUS',
      'FERRY' => 'FERRY',
      'TRAM' => 'TRAM',
      'COMMUTER_TRAIN' || 'RAIL' => 'TRAIN',
      'SHARE_TAXI' => 'AUTO',
      _ => 'OTHER',
    };

class DirectionsException implements Exception {
  DirectionsException(this.status, this.message);
  final String status;
  final String? message;
  @override
  String toString() => 'Directions $status: ${message ?? ''}';
}
