import 'dart:math';
import 'package:flutter/material.dart';
import 'models.dart';
import 'storage.dart';

class AppState extends ChangeNotifier {
  AppData _data = AppData(lvs: [], entries: [], settings: AppSettings());
  bool _loaded = false;

  List<Lv> get lvs {
  final list = [..._data.lvs];
  list.sort((a, b) => a.title.compareTo(b.title));
  return list;
}
  List<ScheduleEntry> get entries => _data.entries;
  AppSettings get settings => _data.settings;

  bool get loaded => _loaded;

  Future<void> init() async {
    _data = await Storage.load();
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async => Storage.save(_data);

  String _id() => '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';

  // LVs
  Future<void> addLv({required String title, String lecturer = ''}) async {
    _data.lvs.add(Lv(id: _id(), title: title, lecturer: lecturer));
    await _persist();
    notifyListeners();
  }

  Future<void> updateLv(Lv lv) async {
    await _persist();
    notifyListeners();
  }

  Future<void> deleteLv(String lvId) async {
    _data.lvs.removeWhere((lv) => lv.id == lvId);
    _data.entries.removeWhere((e) => e.lvId == lvId);
    await _persist();
    notifyListeners();
  }

  Lv? lvById(String id) => _data.lvs.where((e) => e.id == id).cast<Lv?>().firstWhere(
        (e) => e?.id == id,
        orElse: () => null,
      );

  // Termine
  Future<void> addEntry(ScheduleEntry entry) async {
    _data.entries.add(entry);
    await _persist();
    notifyListeners();
  }

  Future<void> updateEntry(ScheduleEntry entry) async {
    await _persist();
    notifyListeners();
  }

  Future<void> deleteEntry(String entryId) async {
    _data.entries.removeWhere((e) => e.id == entryId);
    await _persist();
    notifyListeners();
  }

  List<ScheduleEntry> entriesForWeekday(int weekday) {
    final list = _data.entries.where((e) => e.weekday == weekday).toList();
    list.sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
    return list;
  }

  // Settings
  Future<void> setDarkMode(bool value) async {
    _data.settings.darkMode = value;
    await _persist();
    notifyListeners();
  }

  Future<void> setDefaultReminder(int minutes) async {
    _data.settings.defaultReminderMinutes = minutes;
    await _persist();
    notifyListeners();
  }

  // Backup/Restore
  Future<String> backup() async {
    final file = await Storage.backupToFile(_data);
    return file.path;
  }

  Future<void> restore() async {
    _data = await Storage.restoreFromFile();
    await _persist();
    notifyListeners();
  }
}
