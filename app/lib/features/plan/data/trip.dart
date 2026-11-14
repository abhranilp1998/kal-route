enum TripStatus { planned, notified, done, skipped }

/// One planned trip for a given day (domain model; persisted in the `trips`
/// table by `PlanRepository`).
class Trip {
  Trip({
    this.id = 0,
    required this.date,
    required this.fromPlaceId,
    required this.toPlaceId,
    required this.arriveBy,
    this.status = TripStatus.planned,
    this.leaveAt,
    this.bufferMinutes = 0,
    this.cachedRouteJson,
    this.routeFetchedAt,
    this.routeSource,
  });

  int id;
  DateTime date; // the day of the trip (date only)
  int fromPlaceId;
  int toPlaceId;
  DateTime arriveBy; // "College at 10"
  TripStatus status;
  DateTime? leaveAt; // route departure minus bufferMinutes
  int bufferMinutes;
  String? cachedRouteJson; // last route fetched
  DateTime? routeFetchedAt;
  String? routeSource;

  /// Legacy (v1 shared_preferences) JSON format, used only by the importer.
  factory Trip.fromLegacyJson(Map<String, dynamic> j) => Trip(
    date: DateTime.parse(j['date'] as String),
    fromPlaceId: j['fromPlaceId'] as int,
    toPlaceId: j['toPlaceId'] as int,
    arriveBy: DateTime.parse(j['arriveBy'] as String),
    status: TripStatus.values.asNameMap()[j['status']] ?? TripStatus.planned,
    leaveAt: j['leaveAt'] == null ? null : DateTime.parse(j['leaveAt'] as String),
    cachedRouteJson: j['cachedRouteJson'] as String?,
  );
}
