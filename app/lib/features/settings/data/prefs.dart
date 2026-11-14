import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  Prefs({
    this.notifyHour = 21,
    this.notifyMinute = 0,
    this.bufferMinutes = 5,
    this.avoidLongWalks = false,
    this.priority = 'fastest',
  });

  int notifyHour;
  int notifyMinute;
  int bufferMinutes; // tea break, slack
  bool avoidLongWalks;
  String priority; // fastest, cheapest, least_changes

  Prefs copyWith({int? notifyHour, int? notifyMinute, int? bufferMinutes, bool? avoidLongWalks, String? priority}) =>
      Prefs(
        notifyHour: notifyHour ?? this.notifyHour,
        notifyMinute: notifyMinute ?? this.notifyMinute,
        bufferMinutes: bufferMinutes ?? this.bufferMinutes,
        avoidLongWalks: avoidLongWalks ?? this.avoidLongWalks,
        priority: priority ?? this.priority,
      );

  Map<String, dynamic> toJson() => {
    'notifyHour': notifyHour,
    'notifyMinute': notifyMinute,
    'bufferMinutes': bufferMinutes,
    'avoidLongWalks': avoidLongWalks,
    'priority': priority,
  };

  factory Prefs.fromJson(Map<String, dynamic> j) => Prefs(
    notifyHour: j['notifyHour'] as int? ?? 21,
    notifyMinute: j['notifyMinute'] as int? ?? 0,
    bufferMinutes: j['bufferMinutes'] as int? ?? 5,
    avoidLongWalks: j['avoidLongWalks'] as bool? ?? false,
    priority: j['priority'] as String? ?? 'fastest',
  );
}

class PrefsStore {
  static const _key = 'prefs_v1';

  static Future<Prefs> load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_key);
    return raw == null ? Prefs() : Prefs.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  static Future<void> save(Prefs p) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_key, jsonEncode(p.toJson()));
  }
}
