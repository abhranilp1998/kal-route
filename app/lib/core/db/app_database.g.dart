// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PlacesTable extends Places with TableInfo<$PlacesTable, PlaceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 60),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('📍'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, lat, lng, address, emoji, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'places';
  @override
  VerificationContext validateIntegrity(Insertable<PlaceRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(_latMeta, lat.isAcceptableOrUnknown(data['lat']!, _latMeta));
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(_lngMeta, lng.isAcceptableOrUnknown(data['lng']!, _lngMeta));
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta, address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('emoji')) {
      context.handle(_emojiMeta, emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaceRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      lat: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}lat'])!,
      lng: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}lng'])!,
      address: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}address']),
      emoji: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}emoji'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PlacesTable createAlias(String alias) {
    return $PlacesTable(attachedDatabase, alias);
  }
}

class PlaceRow extends DataClass implements Insertable<PlaceRow> {
  final int id;
  final String name;
  final double lat;
  final double lng;
  final String? address;
  final String emoji;
  final DateTime createdAt;
  const PlaceRow({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    this.address,
    required this.emoji,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    map['emoji'] = Variable<String>(emoji);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PlacesCompanion toCompanion(bool nullToAbsent) {
    return PlacesCompanion(
      id: Value(id),
      name: Value(name),
      lat: Value(lat),
      lng: Value(lng),
      address: address == null && nullToAbsent ? const Value.absent() : Value(address),
      emoji: Value(emoji),
      createdAt: Value(createdAt),
    );
  }

  factory PlaceRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaceRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      address: serializer.fromJson<String?>(json['address']),
      emoji: serializer.fromJson<String>(json['emoji']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'address': serializer.toJson<String?>(address),
      'emoji': serializer.toJson<String>(emoji),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PlaceRow copyWith({
    int? id,
    String? name,
    double? lat,
    double? lng,
    Value<String?> address = const Value.absent(),
    String? emoji,
    DateTime? createdAt,
  }) => PlaceRow(
    id: id ?? this.id,
    name: name ?? this.name,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    address: address.present ? address.value : this.address,
    emoji: emoji ?? this.emoji,
    createdAt: createdAt ?? this.createdAt,
  );
  PlaceRow copyWithCompanion(PlacesCompanion data) {
    return PlaceRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      address: data.address.present ? data.address.value : this.address,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaceRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('address: $address, ')
          ..write('emoji: $emoji, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, lat, lng, address, emoji, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaceRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.address == this.address &&
          other.emoji == this.emoji &&
          other.createdAt == this.createdAt);
}

class PlacesCompanion extends UpdateCompanion<PlaceRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> lat;
  final Value<double> lng;
  final Value<String?> address;
  final Value<String> emoji;
  final Value<DateTime> createdAt;
  const PlacesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.address = const Value.absent(),
    this.emoji = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PlacesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required double lat,
    required double lng,
    this.address = const Value.absent(),
    this.emoji = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       lat = Value(lat),
       lng = Value(lng);
  static Insertable<PlaceRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<String>? address,
    Expression<String>? emoji,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (address != null) 'address': address,
      if (emoji != null) 'emoji': emoji,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PlacesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<double>? lat,
    Value<double>? lng,
    Value<String?>? address,
    Value<String>? emoji,
    Value<DateTime>? createdAt,
  }) {
    return PlacesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      address: address ?? this.address,
      emoji: emoji ?? this.emoji,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlacesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('address: $address, ')
          ..write('emoji: $emoji, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TripsTable extends Trips with TableInfo<$TripsTable, TripRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromPlaceIdMeta = const VerificationMeta('fromPlaceId');
  @override
  late final GeneratedColumn<int> fromPlaceId = GeneratedColumn<int>(
    'from_place_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES places (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _toPlaceIdMeta = const VerificationMeta('toPlaceId');
  @override
  late final GeneratedColumn<int> toPlaceId = GeneratedColumn<int>(
    'to_place_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES places (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _arriveByMeta = const VerificationMeta('arriveBy');
  @override
  late final GeneratedColumn<DateTime> arriveBy = GeneratedColumn<DateTime>(
    'arrive_by',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TripStatus, String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(TripStatus.planned.name),
  ).withConverter<TripStatus>($TripsTable.$converterstatus);
  static const VerificationMeta _leaveAtMeta = const VerificationMeta('leaveAt');
  @override
  late final GeneratedColumn<DateTime> leaveAt = GeneratedColumn<DateTime>(
    'leave_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bufferMinutesMeta = const VerificationMeta('bufferMinutes');
  @override
  late final GeneratedColumn<int> bufferMinutes = GeneratedColumn<int>(
    'buffer_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _routeJsonMeta = const VerificationMeta('routeJson');
  @override
  late final GeneratedColumn<String> routeJson = GeneratedColumn<String>(
    'route_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _routeFetchedAtMeta = const VerificationMeta('routeFetchedAt');
  @override
  late final GeneratedColumn<DateTime> routeFetchedAt = GeneratedColumn<DateTime>(
    'route_fetched_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _routeSourceMeta = const VerificationMeta('routeSource');
  @override
  late final GeneratedColumn<String> routeSource = GeneratedColumn<String>(
    'route_source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    fromPlaceId,
    toPlaceId,
    arriveBy,
    status,
    leaveAt,
    bufferMinutes,
    routeJson,
    routeFetchedAt,
    routeSource,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trips';
  @override
  VerificationContext validateIntegrity(Insertable<TripRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(_dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('from_place_id')) {
      context.handle(_fromPlaceIdMeta, fromPlaceId.isAcceptableOrUnknown(data['from_place_id']!, _fromPlaceIdMeta));
    } else if (isInserting) {
      context.missing(_fromPlaceIdMeta);
    }
    if (data.containsKey('to_place_id')) {
      context.handle(_toPlaceIdMeta, toPlaceId.isAcceptableOrUnknown(data['to_place_id']!, _toPlaceIdMeta));
    } else if (isInserting) {
      context.missing(_toPlaceIdMeta);
    }
    if (data.containsKey('arrive_by')) {
      context.handle(_arriveByMeta, arriveBy.isAcceptableOrUnknown(data['arrive_by']!, _arriveByMeta));
    } else if (isInserting) {
      context.missing(_arriveByMeta);
    }
    if (data.containsKey('leave_at')) {
      context.handle(_leaveAtMeta, leaveAt.isAcceptableOrUnknown(data['leave_at']!, _leaveAtMeta));
    }
    if (data.containsKey('buffer_minutes')) {
      context.handle(
        _bufferMinutesMeta,
        bufferMinutes.isAcceptableOrUnknown(data['buffer_minutes']!, _bufferMinutesMeta),
      );
    }
    if (data.containsKey('route_json')) {
      context.handle(_routeJsonMeta, routeJson.isAcceptableOrUnknown(data['route_json']!, _routeJsonMeta));
    }
    if (data.containsKey('route_fetched_at')) {
      context.handle(
        _routeFetchedAtMeta,
        routeFetchedAt.isAcceptableOrUnknown(data['route_fetched_at']!, _routeFetchedAtMeta),
      );
    }
    if (data.containsKey('route_source')) {
      context.handle(_routeSourceMeta, routeSource.isAcceptableOrUnknown(data['route_source']!, _routeSourceMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TripRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      fromPlaceId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}from_place_id'])!,
      toPlaceId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}to_place_id'])!,
      arriveBy: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}arrive_by'])!,
      status: $TripsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      ),
      leaveAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}leave_at']),
      bufferMinutes: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}buffer_minutes'])!,
      routeJson: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}route_json']),
      routeFetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}route_fetched_at'],
      ),
      routeSource: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}route_source']),
    );
  }

  @override
  $TripsTable createAlias(String alias) {
    return $TripsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TripStatus, String, String> $converterstatus = const EnumNameConverter<TripStatus>(
    TripStatus.values,
  );
}

class TripRow extends DataClass implements Insertable<TripRow> {
  final int id;

  /// Local midnight of the trip day.
  final DateTime date;
  final int fromPlaceId;
  final int toPlaceId;
  final DateTime arriveBy;
  final TripStatus status;

  /// When to walk out of the door = route departure − [bufferMinutes].
  final DateTime? leaveAt;

  /// Buffer used when [leaveAt] was computed, so the timeline can show it.
  final int bufferMinutes;

  /// Best route as JSON (RouteResult.toJson) so the card works offline.
  final String? routeJson;
  final DateTime? routeFetchedAt;
  final String? routeSource;
  const TripRow({
    required this.id,
    required this.date,
    required this.fromPlaceId,
    required this.toPlaceId,
    required this.arriveBy,
    required this.status,
    this.leaveAt,
    required this.bufferMinutes,
    this.routeJson,
    this.routeFetchedAt,
    this.routeSource,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['from_place_id'] = Variable<int>(fromPlaceId);
    map['to_place_id'] = Variable<int>(toPlaceId);
    map['arrive_by'] = Variable<DateTime>(arriveBy);
    {
      map['status'] = Variable<String>($TripsTable.$converterstatus.toSql(status));
    }
    if (!nullToAbsent || leaveAt != null) {
      map['leave_at'] = Variable<DateTime>(leaveAt);
    }
    map['buffer_minutes'] = Variable<int>(bufferMinutes);
    if (!nullToAbsent || routeJson != null) {
      map['route_json'] = Variable<String>(routeJson);
    }
    if (!nullToAbsent || routeFetchedAt != null) {
      map['route_fetched_at'] = Variable<DateTime>(routeFetchedAt);
    }
    if (!nullToAbsent || routeSource != null) {
      map['route_source'] = Variable<String>(routeSource);
    }
    return map;
  }

  TripsCompanion toCompanion(bool nullToAbsent) {
    return TripsCompanion(
      id: Value(id),
      date: Value(date),
      fromPlaceId: Value(fromPlaceId),
      toPlaceId: Value(toPlaceId),
      arriveBy: Value(arriveBy),
      status: Value(status),
      leaveAt: leaveAt == null && nullToAbsent ? const Value.absent() : Value(leaveAt),
      bufferMinutes: Value(bufferMinutes),
      routeJson: routeJson == null && nullToAbsent ? const Value.absent() : Value(routeJson),
      routeFetchedAt: routeFetchedAt == null && nullToAbsent ? const Value.absent() : Value(routeFetchedAt),
      routeSource: routeSource == null && nullToAbsent ? const Value.absent() : Value(routeSource),
    );
  }

  factory TripRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripRow(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      fromPlaceId: serializer.fromJson<int>(json['fromPlaceId']),
      toPlaceId: serializer.fromJson<int>(json['toPlaceId']),
      arriveBy: serializer.fromJson<DateTime>(json['arriveBy']),
      status: $TripsTable.$converterstatus.fromJson(serializer.fromJson<String>(json['status'])),
      leaveAt: serializer.fromJson<DateTime?>(json['leaveAt']),
      bufferMinutes: serializer.fromJson<int>(json['bufferMinutes']),
      routeJson: serializer.fromJson<String?>(json['routeJson']),
      routeFetchedAt: serializer.fromJson<DateTime?>(json['routeFetchedAt']),
      routeSource: serializer.fromJson<String?>(json['routeSource']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'fromPlaceId': serializer.toJson<int>(fromPlaceId),
      'toPlaceId': serializer.toJson<int>(toPlaceId),
      'arriveBy': serializer.toJson<DateTime>(arriveBy),
      'status': serializer.toJson<String>($TripsTable.$converterstatus.toJson(status)),
      'leaveAt': serializer.toJson<DateTime?>(leaveAt),
      'bufferMinutes': serializer.toJson<int>(bufferMinutes),
      'routeJson': serializer.toJson<String?>(routeJson),
      'routeFetchedAt': serializer.toJson<DateTime?>(routeFetchedAt),
      'routeSource': serializer.toJson<String?>(routeSource),
    };
  }

  TripRow copyWith({
    int? id,
    DateTime? date,
    int? fromPlaceId,
    int? toPlaceId,
    DateTime? arriveBy,
    TripStatus? status,
    Value<DateTime?> leaveAt = const Value.absent(),
    int? bufferMinutes,
    Value<String?> routeJson = const Value.absent(),
    Value<DateTime?> routeFetchedAt = const Value.absent(),
    Value<String?> routeSource = const Value.absent(),
  }) => TripRow(
    id: id ?? this.id,
    date: date ?? this.date,
    fromPlaceId: fromPlaceId ?? this.fromPlaceId,
    toPlaceId: toPlaceId ?? this.toPlaceId,
    arriveBy: arriveBy ?? this.arriveBy,
    status: status ?? this.status,
    leaveAt: leaveAt.present ? leaveAt.value : this.leaveAt,
    bufferMinutes: bufferMinutes ?? this.bufferMinutes,
    routeJson: routeJson.present ? routeJson.value : this.routeJson,
    routeFetchedAt: routeFetchedAt.present ? routeFetchedAt.value : this.routeFetchedAt,
    routeSource: routeSource.present ? routeSource.value : this.routeSource,
  );
  TripRow copyWithCompanion(TripsCompanion data) {
    return TripRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      fromPlaceId: data.fromPlaceId.present ? data.fromPlaceId.value : this.fromPlaceId,
      toPlaceId: data.toPlaceId.present ? data.toPlaceId.value : this.toPlaceId,
      arriveBy: data.arriveBy.present ? data.arriveBy.value : this.arriveBy,
      status: data.status.present ? data.status.value : this.status,
      leaveAt: data.leaveAt.present ? data.leaveAt.value : this.leaveAt,
      bufferMinutes: data.bufferMinutes.present ? data.bufferMinutes.value : this.bufferMinutes,
      routeJson: data.routeJson.present ? data.routeJson.value : this.routeJson,
      routeFetchedAt: data.routeFetchedAt.present ? data.routeFetchedAt.value : this.routeFetchedAt,
      routeSource: data.routeSource.present ? data.routeSource.value : this.routeSource,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('fromPlaceId: $fromPlaceId, ')
          ..write('toPlaceId: $toPlaceId, ')
          ..write('arriveBy: $arriveBy, ')
          ..write('status: $status, ')
          ..write('leaveAt: $leaveAt, ')
          ..write('bufferMinutes: $bufferMinutes, ')
          ..write('routeJson: $routeJson, ')
          ..write('routeFetchedAt: $routeFetchedAt, ')
          ..write('routeSource: $routeSource')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    fromPlaceId,
    toPlaceId,
    arriveBy,
    status,
    leaveAt,
    bufferMinutes,
    routeJson,
    routeFetchedAt,
    routeSource,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.fromPlaceId == this.fromPlaceId &&
          other.toPlaceId == this.toPlaceId &&
          other.arriveBy == this.arriveBy &&
          other.status == this.status &&
          other.leaveAt == this.leaveAt &&
          other.bufferMinutes == this.bufferMinutes &&
          other.routeJson == this.routeJson &&
          other.routeFetchedAt == this.routeFetchedAt &&
          other.routeSource == this.routeSource);
}

class TripsCompanion extends UpdateCompanion<TripRow> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<int> fromPlaceId;
  final Value<int> toPlaceId;
  final Value<DateTime> arriveBy;
  final Value<TripStatus> status;
  final Value<DateTime?> leaveAt;
  final Value<int> bufferMinutes;
  final Value<String?> routeJson;
  final Value<DateTime?> routeFetchedAt;
  final Value<String?> routeSource;
  const TripsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.fromPlaceId = const Value.absent(),
    this.toPlaceId = const Value.absent(),
    this.arriveBy = const Value.absent(),
    this.status = const Value.absent(),
    this.leaveAt = const Value.absent(),
    this.bufferMinutes = const Value.absent(),
    this.routeJson = const Value.absent(),
    this.routeFetchedAt = const Value.absent(),
    this.routeSource = const Value.absent(),
  });
  TripsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required int fromPlaceId,
    required int toPlaceId,
    required DateTime arriveBy,
    this.status = const Value.absent(),
    this.leaveAt = const Value.absent(),
    this.bufferMinutes = const Value.absent(),
    this.routeJson = const Value.absent(),
    this.routeFetchedAt = const Value.absent(),
    this.routeSource = const Value.absent(),
  }) : date = Value(date),
       fromPlaceId = Value(fromPlaceId),
       toPlaceId = Value(toPlaceId),
       arriveBy = Value(arriveBy);
  static Insertable<TripRow> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<int>? fromPlaceId,
    Expression<int>? toPlaceId,
    Expression<DateTime>? arriveBy,
    Expression<String>? status,
    Expression<DateTime>? leaveAt,
    Expression<int>? bufferMinutes,
    Expression<String>? routeJson,
    Expression<DateTime>? routeFetchedAt,
    Expression<String>? routeSource,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (fromPlaceId != null) 'from_place_id': fromPlaceId,
      if (toPlaceId != null) 'to_place_id': toPlaceId,
      if (arriveBy != null) 'arrive_by': arriveBy,
      if (status != null) 'status': status,
      if (leaveAt != null) 'leave_at': leaveAt,
      if (bufferMinutes != null) 'buffer_minutes': bufferMinutes,
      if (routeJson != null) 'route_json': routeJson,
      if (routeFetchedAt != null) 'route_fetched_at': routeFetchedAt,
      if (routeSource != null) 'route_source': routeSource,
    });
  }

  TripsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<int>? fromPlaceId,
    Value<int>? toPlaceId,
    Value<DateTime>? arriveBy,
    Value<TripStatus>? status,
    Value<DateTime?>? leaveAt,
    Value<int>? bufferMinutes,
    Value<String?>? routeJson,
    Value<DateTime?>? routeFetchedAt,
    Value<String?>? routeSource,
  }) {
    return TripsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      fromPlaceId: fromPlaceId ?? this.fromPlaceId,
      toPlaceId: toPlaceId ?? this.toPlaceId,
      arriveBy: arriveBy ?? this.arriveBy,
      status: status ?? this.status,
      leaveAt: leaveAt ?? this.leaveAt,
      bufferMinutes: bufferMinutes ?? this.bufferMinutes,
      routeJson: routeJson ?? this.routeJson,
      routeFetchedAt: routeFetchedAt ?? this.routeFetchedAt,
      routeSource: routeSource ?? this.routeSource,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (fromPlaceId.present) {
      map['from_place_id'] = Variable<int>(fromPlaceId.value);
    }
    if (toPlaceId.present) {
      map['to_place_id'] = Variable<int>(toPlaceId.value);
    }
    if (arriveBy.present) {
      map['arrive_by'] = Variable<DateTime>(arriveBy.value);
    }
    if (status.present) {
      map['status'] = Variable<String>($TripsTable.$converterstatus.toSql(status.value));
    }
    if (leaveAt.present) {
      map['leave_at'] = Variable<DateTime>(leaveAt.value);
    }
    if (bufferMinutes.present) {
      map['buffer_minutes'] = Variable<int>(bufferMinutes.value);
    }
    if (routeJson.present) {
      map['route_json'] = Variable<String>(routeJson.value);
    }
    if (routeFetchedAt.present) {
      map['route_fetched_at'] = Variable<DateTime>(routeFetchedAt.value);
    }
    if (routeSource.present) {
      map['route_source'] = Variable<String>(routeSource.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('fromPlaceId: $fromPlaceId, ')
          ..write('toPlaceId: $toPlaceId, ')
          ..write('arriveBy: $arriveBy, ')
          ..write('status: $status, ')
          ..write('leaveAt: $leaveAt, ')
          ..write('bufferMinutes: $bufferMinutes, ')
          ..write('routeJson: $routeJson, ')
          ..write('routeFetchedAt: $routeFetchedAt, ')
          ..write('routeSource: $routeSource')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PlacesTable places = $PlacesTable(this);
  late final $TripsTable trips = $TripsTable(this);
  late final Index tripsDateIdx = Index('trips_date_idx', 'CREATE INDEX trips_date_idx ON trips (date)');
  late final Index tripsStatusIdx = Index('trips_status_idx', 'CREATE INDEX trips_status_idx ON trips (status)');
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [places, trips, tripsDateIdx, tripsStatusIdx];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName('places', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('trips', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('places', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('trips', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$PlacesTableCreateCompanionBuilder = PlacesCompanion Function({
  Value<int> id,
  required String name,
  required double lat,
  required double lng,
  Value<String?> address,
  Value<String> emoji,
  Value<DateTime> createdAt,
});
typedef $$PlacesTableUpdateCompanionBuilder = PlacesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<double> lat,
  Value<double> lng,
  Value<String?> address,
  Value<String> emoji,
  Value<DateTime> createdAt,
});

final class $$PlacesTableReferences extends BaseReferences<_$AppDatabase, $PlacesTable, PlaceRow> {
  $$PlacesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TripsTable, List<TripRow>> _departingTripsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.trips, aliasName: 'places__id__trips__from_place_id');

  $$TripsTableProcessedTableManager get departingTrips {
    final manager = $$TripsTableTableManager(
      $_db,
      $_db.trips,
    ).filter((f) => f.fromPlaceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_departingTripsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TripsTable, List<TripRow>> _arrivingTripsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.trips, aliasName: 'places__id__trips__to_place_id');

  $$TripsTableProcessedTableManager get arrivingTrips {
    final manager = $$TripsTableTableManager(
      $_db,
      $_db.trips,
    ).filter((f) => f.toPlaceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_arrivingTripsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PlacesTableFilterComposer extends Composer<_$AppDatabase, $PlacesTable> {
  $$PlacesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lat => $composableBuilder(column: $table.lat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lng => $composableBuilder(column: $table.lng, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> departingTrips(Expression<bool> Function($$TripsTableFilterComposer f) f) {
    final $$TripsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.fromPlaceId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TripsTableFilterComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> arrivingTrips(Expression<bool> Function($$TripsTableFilterComposer f) f) {
    final $$TripsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.toPlaceId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TripsTableFilterComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlacesTableOrderingComposer extends Composer<_$AppDatabase, $PlacesTable> {
  $$PlacesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$PlacesTableAnnotationComposer extends Composer<_$AppDatabase, $PlacesTable> {
  $$PlacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get lat => $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng => $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<String> get address => $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get emoji => $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> departingTrips<T extends Object>(Expression<T> Function($$TripsTableAnnotationComposer a) f) {
    final $$TripsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.fromPlaceId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TripsTableAnnotationComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> arrivingTrips<T extends Object>(Expression<T> Function($$TripsTableAnnotationComposer a) f) {
    final $$TripsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.toPlaceId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TripsTableAnnotationComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlacesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlacesTable,
          PlaceRow,
          $$PlacesTableFilterComposer,
          $$PlacesTableOrderingComposer,
          $$PlacesTableAnnotationComposer,
          $$PlacesTableCreateCompanionBuilder,
          $$PlacesTableUpdateCompanionBuilder,
          (PlaceRow, $$PlacesTableReferences),
          PlaceRow,
          PrefetchHooks Function({bool departingTrips, bool arrivingTrips})
        > {
  $$PlacesTableTableManager(_$AppDatabase db, $PlacesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$PlacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$PlacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$PlacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lng = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PlacesCompanion(
                id: id,
                name: name,
                lat: lat,
                lng: lng,
                address: address,
                emoji: emoji,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required double lat,
                required double lng,
                Value<String?> address = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PlacesCompanion.insert(
                id: id,
                name: name,
                lat: lat,
                lng: lng,
                address: address,
                emoji: emoji,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable<$PlacesTable, PlaceRow>(table), $$PlacesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({departingTrips = false, arrivingTrips = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (departingTrips) db.trips, if (arrivingTrips) db.trips],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (departingTrips)
                    await $_getPrefetchedDataByColumns<PlaceRow, $PlacesTable, TripRow, $TripsTable>(
                      currentTable: table,
                      referencedTable: $$PlacesTableReferences._departingTripsTable(db),
                      managerFromTypedResult: (p0) => $$PlacesTableReferences(db, table, p0).departingTrips,
                      currentColumn: 'id',
                      referencedColumn: 'from_place_id',
                      typedResults: items,
                    ),
                  if (arrivingTrips)
                    await $_getPrefetchedDataByColumns<PlaceRow, $PlacesTable, TripRow, $TripsTable>(
                      currentTable: table,
                      referencedTable: $$PlacesTableReferences._arrivingTripsTable(db),
                      managerFromTypedResult: (p0) => $$PlacesTableReferences(db, table, p0).arrivingTrips,
                      currentColumn: 'id',
                      referencedColumn: 'to_place_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PlacesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlacesTable,
      PlaceRow,
      $$PlacesTableFilterComposer,
      $$PlacesTableOrderingComposer,
      $$PlacesTableAnnotationComposer,
      $$PlacesTableCreateCompanionBuilder,
      $$PlacesTableUpdateCompanionBuilder,
      (PlaceRow, $$PlacesTableReferences),
      PlaceRow,
      PrefetchHooks Function({bool departingTrips, bool arrivingTrips})
    >;
typedef $$TripsTableCreateCompanionBuilder = TripsCompanion Function({
  Value<int> id,
  required DateTime date,
  required int fromPlaceId,
  required int toPlaceId,
  required DateTime arriveBy,
  Value<TripStatus> status,
  Value<DateTime?> leaveAt,
  Value<int> bufferMinutes,
  Value<String?> routeJson,
  Value<DateTime?> routeFetchedAt,
  Value<String?> routeSource,
});
typedef $$TripsTableUpdateCompanionBuilder = TripsCompanion Function({
  Value<int> id,
  Value<DateTime> date,
  Value<int> fromPlaceId,
  Value<int> toPlaceId,
  Value<DateTime> arriveBy,
  Value<TripStatus> status,
  Value<DateTime?> leaveAt,
  Value<int> bufferMinutes,
  Value<String?> routeJson,
  Value<DateTime?> routeFetchedAt,
  Value<String?> routeSource,
});

final class $$TripsTableReferences extends BaseReferences<_$AppDatabase, $TripsTable, TripRow> {
  $$TripsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlacesTable _fromPlaceIdTable(_$AppDatabase db) => db.places.createAlias('trips__from_place_id__places__id');

  $$PlacesTableProcessedTableManager get fromPlaceId {
    final $_column = $_itemColumn<int>('from_place_id')!;

    final manager = $$PlacesTableTableManager($_db, $_db.places).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fromPlaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static $PlacesTable _toPlaceIdTable(_$AppDatabase db) => db.places.createAlias('trips__to_place_id__places__id');

  $$PlacesTableProcessedTableManager get toPlaceId {
    final $_column = $_itemColumn<int>('to_place_id')!;

    final manager = $$PlacesTableTableManager($_db, $_db.places).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_toPlaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TripsTableFilterComposer extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get arriveBy =>
      $composableBuilder(column: $table.arriveBy, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<TripStatus, TripStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get leaveAt =>
      $composableBuilder(column: $table.leaveAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bufferMinutes =>
      $composableBuilder(column: $table.bufferMinutes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get routeJson =>
      $composableBuilder(column: $table.routeJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get routeFetchedAt =>
      $composableBuilder(column: $table.routeFetchedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get routeSource =>
      $composableBuilder(column: $table.routeSource, builder: (column) => ColumnFilters(column));

  $$PlacesTableFilterComposer get fromPlaceId {
    final $$PlacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromPlaceId,
      referencedTable: $db.places,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$PlacesTableFilterComposer(
            $db: $db,
            $table: $db.places,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlacesTableFilterComposer get toPlaceId {
    final $$PlacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toPlaceId,
      referencedTable: $db.places,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$PlacesTableFilterComposer(
            $db: $db,
            $table: $db.places,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripsTableOrderingComposer extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get arriveBy =>
      $composableBuilder(column: $table.arriveBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get leaveAt =>
      $composableBuilder(column: $table.leaveAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bufferMinutes =>
      $composableBuilder(column: $table.bufferMinutes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get routeJson =>
      $composableBuilder(column: $table.routeJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get routeFetchedAt =>
      $composableBuilder(column: $table.routeFetchedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get routeSource =>
      $composableBuilder(column: $table.routeSource, builder: (column) => ColumnOrderings(column));

  $$PlacesTableOrderingComposer get fromPlaceId {
    final $$PlacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromPlaceId,
      referencedTable: $db.places,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$PlacesTableOrderingComposer(
            $db: $db,
            $table: $db.places,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlacesTableOrderingComposer get toPlaceId {
    final $$PlacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toPlaceId,
      referencedTable: $db.places,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$PlacesTableOrderingComposer(
            $db: $db,
            $table: $db.places,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripsTableAnnotationComposer extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date => $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get arriveBy => $composableBuilder(column: $table.arriveBy, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TripStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get leaveAt => $composableBuilder(column: $table.leaveAt, builder: (column) => column);

  GeneratedColumn<int> get bufferMinutes =>
      $composableBuilder(column: $table.bufferMinutes, builder: (column) => column);

  GeneratedColumn<String> get routeJson => $composableBuilder(column: $table.routeJson, builder: (column) => column);

  GeneratedColumn<DateTime> get routeFetchedAt =>
      $composableBuilder(column: $table.routeFetchedAt, builder: (column) => column);

  GeneratedColumn<String> get routeSource =>
      $composableBuilder(column: $table.routeSource, builder: (column) => column);

  $$PlacesTableAnnotationComposer get fromPlaceId {
    final $$PlacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromPlaceId,
      referencedTable: $db.places,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$PlacesTableAnnotationComposer(
            $db: $db,
            $table: $db.places,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlacesTableAnnotationComposer get toPlaceId {
    final $$PlacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toPlaceId,
      referencedTable: $db.places,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$PlacesTableAnnotationComposer(
            $db: $db,
            $table: $db.places,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripsTable,
          TripRow,
          $$TripsTableFilterComposer,
          $$TripsTableOrderingComposer,
          $$TripsTableAnnotationComposer,
          $$TripsTableCreateCompanionBuilder,
          $$TripsTableUpdateCompanionBuilder,
          (TripRow, $$TripsTableReferences),
          TripRow,
          PrefetchHooks Function({bool fromPlaceId, bool toPlaceId})
        > {
  $$TripsTableTableManager(_$AppDatabase db, $TripsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$TripsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$TripsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$TripsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> fromPlaceId = const Value.absent(),
                Value<int> toPlaceId = const Value.absent(),
                Value<DateTime> arriveBy = const Value.absent(),
                Value<TripStatus> status = const Value.absent(),
                Value<DateTime?> leaveAt = const Value.absent(),
                Value<int> bufferMinutes = const Value.absent(),
                Value<String?> routeJson = const Value.absent(),
                Value<DateTime?> routeFetchedAt = const Value.absent(),
                Value<String?> routeSource = const Value.absent(),
              }) => TripsCompanion(
                id: id,
                date: date,
                fromPlaceId: fromPlaceId,
                toPlaceId: toPlaceId,
                arriveBy: arriveBy,
                status: status,
                leaveAt: leaveAt,
                bufferMinutes: bufferMinutes,
                routeJson: routeJson,
                routeFetchedAt: routeFetchedAt,
                routeSource: routeSource,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required int fromPlaceId,
                required int toPlaceId,
                required DateTime arriveBy,
                Value<TripStatus> status = const Value.absent(),
                Value<DateTime?> leaveAt = const Value.absent(),
                Value<int> bufferMinutes = const Value.absent(),
                Value<String?> routeJson = const Value.absent(),
                Value<DateTime?> routeFetchedAt = const Value.absent(),
                Value<String?> routeSource = const Value.absent(),
              }) => TripsCompanion.insert(
                id: id,
                date: date,
                fromPlaceId: fromPlaceId,
                toPlaceId: toPlaceId,
                arriveBy: arriveBy,
                status: status,
                leaveAt: leaveAt,
                bufferMinutes: bufferMinutes,
                routeJson: routeJson,
                routeFetchedAt: routeFetchedAt,
                routeSource: routeSource,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable<$TripsTable, TripRow>(table), $$TripsTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({fromPlaceId = false, toPlaceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (fromPlaceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.fromPlaceId,
                        referencedTable: $$TripsTableReferences._fromPlaceIdTable(db),
                        referencedColumn: $$TripsTableReferences._fromPlaceIdTable(db).id,
                      ) as T;
                    }
                    if (toPlaceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.toPlaceId,
                        referencedTable: $$TripsTableReferences._toPlaceIdTable(db),
                        referencedColumn: $$TripsTableReferences._toPlaceIdTable(db).id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TripsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripsTable,
      TripRow,
      $$TripsTableFilterComposer,
      $$TripsTableOrderingComposer,
      $$TripsTableAnnotationComposer,
      $$TripsTableCreateCompanionBuilder,
      $$TripsTableUpdateCompanionBuilder,
      (TripRow, $$TripsTableReferences),
      TripRow,
      PrefetchHooks Function({bool fromPlaceId, bool toPlaceId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PlacesTableTableManager get places => $$PlacesTableTableManager(_db, _db.places);
  $$TripsTableTableManager get trips => $$TripsTableTableManager(_db, _db.trips);
}
