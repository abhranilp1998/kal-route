/// A saved place, e.g. "Home" or "College" (domain model; persisted in the
/// `places` table by `PlaceRepository`).
class Place {
  Place({this.id = 0, required this.name, required this.lat, required this.lng, this.address, this.emoji = '📍'});

  int id;
  String name;
  double lat;
  double lng;
  String? address;
  String emoji;

  Place copyWith({int? id, String? name, double? lat, double? lng, String? address, String? emoji}) => Place(
    id: id ?? this.id,
    name: name ?? this.name,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    address: address ?? this.address,
    emoji: emoji ?? this.emoji,
  );

  /// Legacy (v1 shared_preferences) JSON format, used only by the importer.
  factory Place.fromLegacyJson(Map<String, dynamic> j) => Place(
    id: j['id'] as int,
    name: j['name'] as String,
    lat: (j['lat'] as num).toDouble(),
    lng: (j['lng'] as num).toDouble(),
    address: j['address'] as String?,
    emoji: (j['emoji'] as String?) ?? '📍',
  );
}
