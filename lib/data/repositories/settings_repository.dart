import 'package:sqflite/sqflite.dart';
import '../../domain/models/academic_settings.dart';

class SettingsRepository {
  final Database db;

  SettingsRepository(this.db);

  Future<String?> getString(String key) async {
    final maps = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    if (maps.isEmpty) return null;
    return maps.first['value'] as String?;
  }

  Future<void> setString(String key, String value) async {
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final val = await getString(key);
    if (val == null) return defaultValue;
    return val == 'true' || val == '1';
  }

  Future<void> setBool(String key, bool value) async {
    await setString(key, value ? 'true' : 'false');
  }

  Future<AcademicSettings> getAcademicSettings() async {
    final gradeScaleStr = await getString('grade_scale');
    final minAttStr = await getString('min_attendance_percent');
    final map = <String, dynamic>{};
    if (gradeScaleStr != null) map['grade_scale'] = gradeScaleStr;
    if (minAttStr != null) map['min_attendance_percent'] = double.tryParse(minAttStr) ?? 80.0;
    return AcademicSettings.fromMap(map);
  }

  Future<void> saveAcademicSettings(AcademicSettings settings) async {
    final map = settings.toMap();
    await setString('grade_scale', map['grade_scale'] as String);
    await setString('min_attendance_percent', map['min_attendance_percent'].toString());
  }
}
