import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class Storage {
  static const _key = 'app_data_v1';

  static Future<AppData> load() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_key);
    if (s == null || s.isEmpty) {
      return AppData(lvs: [], entries: [], settings: AppSettings());
    }
    return AppData.fromJsonString(s);
    }

  static Future<void> save(AppData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, data.toJsonString());
  }

  // Backup/Restore als JSON-Datei im Dokumente-Ordner
  static Future<File> backupToFile(AppData data) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/stundenplan_backup.json');
    return file.writeAsString(data.toJsonString());
  }

  static Future<AppData> restoreFromFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/stundenplan_backup.json');
    if (!await file.exists()) {
      throw Exception('Keine Backup-Datei gefunden: ${file.path}');
    }
    final s = await file.readAsString();
    return AppData.fromJsonString(s);
  }
}
