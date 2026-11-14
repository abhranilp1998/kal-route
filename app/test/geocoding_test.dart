import 'dart:convert';

import 'package:commute_planner/core/geo/geocoding_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const searchBody = '''
[
  {"place_id": 1, "lat": "22.5203", "lon": "88.3468", "name": "Kalighat Temple",
   "display_name": "Kalighat Temple, Kalighat Temple Road, Kalighat, Kolkata, West Bengal, 700026, India",
   "address": {"amenity": "Kalighat Temple", "road": "Kalighat Temple Road", "suburb": "Kalighat", "city": "Kolkata"}},
  {"place_id": 2, "lat": "22.5175", "lon": "88.3440", "name": "",
   "display_name": "Lake Road, Kalighat, Kolkata, West Bengal, India",
   "address": {"road": "Lake Road", "neighbourhood": "Kalighat", "city": "Kolkata"}}
]''';

const reverseBody = '''
{"place_id": 3, "lat": "22.58671", "lon": "88.41712", "name": "",
 "display_name": "Karunamoyee, Sector II, Bidhannagar, North 24 Parganas, West Bengal, 700091, India",
 "address": {"road": "Karunamoyee Road", "suburb": "Sector II", "city": "Bidhannagar"}}''';

void main() {
  test('parses search results with short labels', () {
    final r = NominatimGeocoder.parseSearch(searchBody);
    expect(r, hasLength(2));
    expect(r[0].lat, 22.5203);
    expect(r[0].lng, 88.3468);
    expect(r[0].shortName, 'Kalighat Temple, Kalighat');
    expect(r[1].shortName, 'Lake Road, Kalighat');
  });

  test('parses reverse result, and returns null for an error body', () {
    final r = NominatimGeocoder.parseReverse(reverseBody, 0, 0)!;
    expect(r.shortName, 'Karunamoyee Road, Sector II');
    expect(r.lat, closeTo(22.58671, 1e-6));
    expect(NominatimGeocoder.parseReverse('{"error": "Unable to geocode"}', 1, 2), isNull);
  });

  test('sends policy-compliant requests, spaces them >= 1 s, and caches', () async {
    final times = <DateTime>[];
    final requests = <http.Request>[];
    final client = MockClient((req) async {
      requests.add(req);
      times.add(DateTime.now());
      return http.Response.bytes(
        utf8.encode(req.url.path == '/search' ? searchBody : reverseBody),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final g = NominatimGeocoder(client: client, minInterval: const Duration(milliseconds: 300));
    final results = await Future.wait([g.search('Kalighat'), g.reverse(22.58671, 88.41712)]);
    expect((results[0] as List<GeoResult>).length, 2);
    expect(requests, hasLength(2));
    expect(times[1].difference(times[0]).inMilliseconds, greaterThanOrEqualTo(290));
    final s = requests.first;
    expect(s.url.queryParameters['format'], 'jsonv2');
    expect(s.url.queryParameters['countrycodes'], 'in');
    expect(s.headers['User-Agent'], contains('CommutePlanner'));

    await g.search('kalighat'); // cached (case-insensitive)
    await g.reverse(22.586712, 88.417121); // cached (5 dp)
    expect(requests, hasLength(2));
  });

  test('short queries do not hit the network; HTTP errors throw', () async {
    var calls = 0;
    final g = NominatimGeocoder(
      client: MockClient((_) async {
        calls++;
        return http.Response('rate limited', 429);
      }),
      minInterval: Duration.zero,
    );
    expect(await g.search('ab'), isEmpty);
    expect(calls, 0);
    await expectLater(g.search('Esplanade'), throwsA(isA<GeocodingException>()));
  });
}
