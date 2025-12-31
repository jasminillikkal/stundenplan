import 'dart:convert';

enum ReminderMode { off, defaultTime, custom }

class Lv {
  final String id;
  String title;
  String lecturer;
  int colorValue; // ARGB int

  Lv({
    required this.id,
    required this.title,
    this.lecturer = '',
    this.colorValue = 0xFF4CAF50,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'lecturer': lecturer,
        'colorValue': colorValue,
      };

  static Lv fromJson(Map<String, dynamic> j) => Lv(
        id: j['id'],
        title: j['title'],
        lecturer: j['lecturer'] ?? '',
        colorValue: j['colorValue'] ?? 0xFF4CAF50,
      );
}

class ScheduleEntry {
  final String id;
  String lvId;
  int weekday; // 1=Mon ... 7=Sun
  int startMinutes; // minutes since 00:00
  int endMinutes;
  String room;

  ReminderMode reminderMode;
  int? customReminderMinutes; // only if custom

  ScheduleEntry({
    required this.id,
    required this.lvId,
    required this.weekday,
    required this.startMinutes,
    required this.endMinutes,
    this.room = '',
    this.reminderMode = ReminderMode.defaultTime,
    this.customReminderMinutes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'lvId': lvId,
        'weekday': weekday,
        'startMinutes': startMinutes,
        'endMinutes': endMinutes,
        'room': room,
        'reminderMode': reminderMode.name,
        'customReminderMinutes': customReminderMinutes,
      };

  static ScheduleEntry fromJson(Map<String, dynamic> j) => ScheduleEntry(
        id: j['id'],
        lvId: j['lvId'],
        weekday: j['weekday'],
        startMinutes: j['startMinutes'],
        endMinutes: j['endMinutes'],
        room: j['room'] ?? '',
        reminderMode: ReminderMode.values.firstWhere(
          (e) => e.name == (j['reminderMode'] ?? 'defaultTime'),
          orElse: () => ReminderMode.defaultTime,
        ),
        customReminderMinutes: j['customReminderMinutes'],
      );
}

class AppSettings {
  int defaultReminderMinutes;
  bool darkMode;

  AppSettings({
    this.defaultReminderMinutes = 15,
    this.darkMode = false,
  });

  Map<String, dynamic> toJson() => {
        'defaultReminderMinutes': defaultReminderMinutes,
        'darkMode': darkMode,
      };

  static AppSettings fromJson(Map<String, dynamic> j) => AppSettings(
        defaultReminderMinutes: j['defaultReminderMinutes'] ?? 15,
        darkMode: j['darkMode'] ?? false,
      );
}

class AppData {
  List<Lv> lvs;
  List<ScheduleEntry> entries;
  AppSettings settings;

  AppData({
    required this.lvs,
    required this.entries,
    required this.settings,
  });

  Map<String, dynamic> toJson() => {
        'lvs': lvs.map((e) => e.toJson()).toList(),
        'entries': entries.map((e) => e.toJson()).toList(),
        'settings': settings.toJson(),
      };

  static AppData fromJson(Map<String, dynamic> j) => AppData(
        lvs: (j['lvs'] as List? ?? []).map((e) => Lv.fromJson(e)).toList(),
        entries: (j['entries'] as List? ?? [])
            .map((e) => ScheduleEntry.fromJson(e))
            .toList(),
        settings: AppSettings.fromJson(j['settings'] ?? {}),
      );

  String toJsonString() => jsonEncode(toJson());

  static AppData fromJsonString(String s) =>
      AppData.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
