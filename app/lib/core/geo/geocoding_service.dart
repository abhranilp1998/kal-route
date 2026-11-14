import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// A geocoding hit (search result or reverse-geocoded pin).
class GeoResult {
  const GeoResult({required this.lat, required this.lng, required this.displayName, required this.shortName});
  final double lat, lng;

  /// Full Nominatim display_name.
  final String displayName;

  /// Compact "Road, Neighbourhood" label used as the saved address.
  final String shortName;

  @override
  String toString() => 'GeoResult($shortName @ $lat,$lng)';
}

/// OpenStreetMap Nominatim client that follows the usage policy
/// (https://operations.osmfoundation.org/policies/nominatim/):
/// * at most 1 request per second (requests are serialised and spaced),
/// * identifies the app with a User-Agent on Android/iOS (browsers forbid
///   setting User-Agent, so on web the browser's UA + Referer identify it),
/// * no search-as-you-type: the UI only searches on submit,
/// * results are cached in memory.
class NominatimGeocoder {
  NominatimGeocoder({
    http.Client? client,
    this.baseUrl = 'https://nominatim.openstreetmap.org',
    this.minInterval = const Duration(milliseconds: 1100),
    DateTime Function()? clock,
  }) : _client = client ?? http.Client(),
       _clock = clock ?? DateTime.now;

  static const userAgent = 'CommutePlanner/1.0 (com.abhranil.commute_planner; personal side project)';

  /// Kolkata metropolitan area, used to bias (not restrict) search results.
  static const kolkataViewbox = '88.20,22.75,88.55,22.40';

  final http.Client _client;
  final String baseUrl;
  final Duration minInterval;
  final DateTime Function() _clock;
  final _cache = <String, Object?>{};
  Future<void> _queue = Future.value();
  DateTime? _last;

  Future<List<GeoResult>> search(String query, {int limit = 6}) async {
    final q = query.trim();
    if (q.length < 3) return const [];
    final key = 's:${q.toLowerCase()}';
    if (_cache[key] case final List<GeoResult> hit) return hit;
    final body = await _get('/search', {
      'q': q,
      'format': 'jsonv2',
      'addressdetails': '1',
      'limit': '$limit',
      'countrycodes': 'in',
      'viewbox': kolkataViewbox,
      'bounded': '0',
      'accept-language': 'en',
    });
    final out = parseSearch(body);
    _cache[key] = out;
    return out;
  }

  Future<GeoResult?> reverse(double lat, double lng) async {
    final key = 'r:${lat.toStringAsFixed(5)},${lng.toStringAsFixed(5)}';
    if (_cache.containsKey(key)) return _cache[key] as GeoResult?;
    final body = await _get('/reverse', {
      'lat': lat.toStringAsFixed(6),
      'lon': lng.toStringAsFixed(6),
      'format': 'jsonv2',
      'zoom': '18',
      'addressdetails': '1',
      'accept-language': 'en',
    });
    final out = parseReverse(body, lat, lng);
    _cache[key] = out;
    return out;
  }

  /// Serialises requests and spaces them by [minInterval].
  Future<String> _get(String path, Map<String, String> params) {
    final completer = Completer<String>();
    _queue = _queue.then((_) async {
      final last = _last;
      if (last != null) {
        final wait = minInterval - _clock().difference(last);
        if (wait > Duration.zero) await Future<void>.delayed(wait);
      }
      _last = _clock();
      try {
        final res = await _client
            .get(
              Uri.parse('$baseUrl$path').replace(queryParameters: params),
              headers: {if (!kIsWeb) 'User-Agent': userAgent, 'Accept': 'application/json'},
            )
            .timeout(const Duration(seconds: 12));
        if (res.statusCode != 200) {
          throw GeocodingException('Nominatim HTTP ${res.statusCode}');
        }
        completer.complete(utf8.decode(res.bodyBytes));
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }

  static List<GeoResult> parseSearch(String body) {
    final list = jsonDecode(body) as List;
    return [
      for (final raw in list.cast<Map<String, dynamic>>())
        GeoResult(
          lat: double.parse(raw['lat'] as String),
          lng: double.parse(raw['lon'] as String),
          displayName: raw['display_name'] as String,
          shortName: shortLabel(raw),
        ),
    ];
  }

  static GeoResult? parseReverse(String body, double lat, double lng) {
    final j = jsonDecode(body) as Map<String, dynamic>;
    if (j.containsKey('error')) return null;
    return GeoResult(
      lat: double.tryParse('${j['lat']}') ?? lat,
      lng: double.tryParse('${j['lon']}') ?? lng,
      displayName: j['display_name'] as String,
      shortName: shortLabel(j),
    );
  }

  /// "Lake Road, Kalighat" style label from Nominatim address details.
  static String shortLabel(Map<String, dynamic> j) {
    final a = (j['address'] as Map?)?.cast<String, dynamic>() ?? const {};
    final name = j['name'] as String?;
    final first = [
      name,
      a['road'],
      a['pedestrian'],
      a['amenity'],
      a['building'],
    ].whereType<String>().where((s) => s.isNotEmpty).firstOrNull;
    final area = [
      a['neighbourhood'],
      a['suburb'],
      a['quarter'],
      a['city_district'],
      a['city'],
      a['town'],
    ].whereType<String>().where((s) => s.isNotEmpty && s != first).firstOrNull;
    final parts = [first, area].whereType<String>().toList();
    if (parts.isNotEmpty) return parts.join(', ');
    return (j['display_name'] as String? ?? '').split(',').take(2).map((s) => s.trim()).join(', ');
  }
}

class GeocodingException implements Exception {
  GeocodingException(this.message);
  final String message;
  @override
  String toString() => message;
}
