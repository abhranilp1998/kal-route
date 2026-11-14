import 'dart:convert';

/// One leg of a route: WALK, METRO, BUS, AUTO, FERRY, TRAM, TRAIN, OTHER.
class RouteLeg {
  const RouteLeg(
    this.mode,
    this.line,
    this.from,
    this.to,
    this.minutes,
    this.fareInr, {
    this.stops,
    this.headsign,
    this.departAt,
  });

  final String mode;
  final String? line; // "Blue Line", "S-12"
  final String from;
  final String to;
  final int minutes;
  final int? fareInr;
  final int? stops;
  final String? headsign;
  final DateTime? departAt;

  bool get isWalk => mode == 'WALK';

  Map<String, dynamic> toJson() => {
    'mode': mode,
    'line': line,
    'from': from,
    'to': to,
    'minutes': minutes,
    'fareInr': fareInr,
    'stops': stops,
    'headsign': headsign,
    'departAt': departAt?.toIso8601String(),
  };

  factory RouteLeg.fromJson(Map<String, dynamic> j) => RouteLeg(
    j['mode'] as String,
    j['line'] as String?,
    j['from'] as String,
    j['to'] as String,
    j['minutes'] as int,
    j['fareInr'] as int?,
    stops: j['stops'] as int?,
    headsign: j['headsign'] as String?,
    departAt: j['departAt'] == null ? null : DateTime.parse(j['departAt'] as String),
  );
}

class RouteResult {
  RouteResult(this.legs, this.leaveAt, this.arriveAt, {this.totalFareInr});

  final List<RouteLeg> legs;
  final DateTime leaveAt, arriveAt;

  /// Google often returns a fare for the whole route but not per leg.
  final int? totalFareInr;

  int get totalMinutes => arriveAt.difference(leaveAt).inMinutes;
  int get fare => totalFareInr ?? legs.fold(0, (s, l) => s + (l.fareInr ?? 0));
  int get walkMinutes => legs.where((l) => l.isWalk).fold(0, (s, l) => s + l.minutes);
  int get transitLegs => legs.where((l) => !l.isWalk).length;

  /// True when Google found no transit at all (only walking), e.g. patchy
  /// Kolkata bus coverage. The UI then suggests an auto or cab instead.
  bool get walkOnly => legs.isNotEmpty && legs.every((l) => l.isWalk);

  String toJson() => jsonEncode({
    'legs': legs.map((l) => l.toJson()).toList(),
    'leaveAt': leaveAt.toIso8601String(),
    'arriveAt': arriveAt.toIso8601String(),
    'totalFareInr': totalFareInr,
  });

  factory RouteResult.fromJson(String s) {
    final j = jsonDecode(s) as Map<String, dynamic>;
    return RouteResult(
      (j['legs'] as List).map((l) => RouteLeg.fromJson(l as Map<String, dynamic>)).toList(),
      DateTime.parse(j['leaveAt'] as String),
      DateTime.parse(j['arriveAt'] as String),
      totalFareInr: j['totalFareInr'] as int?,
    );
  }
}
