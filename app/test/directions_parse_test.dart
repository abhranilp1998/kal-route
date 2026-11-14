import 'dart:convert';
import 'dart:io';

import 'package:commute_planner/core/api/directions_client.dart';
import 'package:commute_planner/features/route/data/route_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Map<String, dynamic> sample;
  setUpAll(() {
    sample = jsonDecode(File('test/fixtures/directions_sample.json').readAsStringSync()) as Map<String, dynamic>;
  });

  test('parses legs, modes, lines and stops from a Directions response', () {
    final routes = parseDirectionsResponse(sample);
    expect(routes, hasLength(2));
    final r = routes.first;
    expect(r.legs.map((l) => l.mode), ['WALK', 'METRO', 'BUS', 'WALK']);
    expect(r.legs[1].line, 'Blue Line');
    expect(r.legs[1].from, 'Kalighat');
    expect(r.legs[1].to, 'Esplanade');
    expect(r.legs[1].stops, 6);
    expect(r.legs[1].headsign, 'Dakshineswar');
    expect(r.legs[2].line, 'S-12');
    expect(r.legs[0].minutes, 6); // 340 s rounds up
    // Walking legs are named after neighbouring stops.
    expect(r.legs[0].to, 'Kalighat');
    expect(r.legs[3].from, 'Karunamoyee');
  });

  test('uses route fare and departure/arrival times', () {
    final r = parseDirectionsResponse(sample).first;
    expect(r.fare, 35);
    expect(r.totalMinutes, 43);
  });

  test('falls back to short_name ?? name and duration when no times', () {
    final r = parseDirectionsResponse(sample)[1];
    expect(r.legs[1].line, '215A');
    expect(r.totalFareInr, isNull);
    expect(r.fare, 0);
    expect(r.totalMinutes, 61);
  });

  test('ZERO_RESULTS returns empty, errors throw', () {
    expect(parseDirectionsResponse({'status': 'ZERO_RESULTS'}), isEmpty);
    expect(
      () => parseDirectionsResponse({'status': 'REQUEST_DENIED', 'error_message': 'bad key'}),
      throwsA(isA<DirectionsException>()),
    );
  });

  test('vehicle type mapping', () {
    expect(mapVehicleType('SUBWAY'), 'METRO');
    expect(mapVehicleType('METRO_RAIL'), 'METRO');
    expect(mapVehicleType('BUS'), 'BUS');
    expect(mapVehicleType('FERRY'), 'FERRY');
    expect(mapVehicleType('SHARE_TAXI'), 'AUTO');
    expect(mapVehicleType('CABLE_CAR'), 'OTHER');
  });

  test('RouteResult JSON round-trip', () {
    final r = parseDirectionsResponse(sample).first;
    final back = RouteResult.fromJson(r.toJson());
    expect(back.legs.length, r.legs.length);
    expect(back.fare, r.fare);
    expect(back.leaveAt, r.leaveAt);
    expect(back.legs[1].stops, 6);
  });
}
