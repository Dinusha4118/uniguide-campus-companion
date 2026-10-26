import 'package:sqflite/sqflite.dart';
import '../../domain/models/attendance_record.dart';

class AttendanceRepository {
  final Database db;

  AttendanceRepository(this.db);

  Future<List<AttendanceRecord>> getAllRecords() async {
    final maps = await db.query('attendance_records', orderBy: 'timestamp DESC');
    return maps.map((m) => AttendanceRecord.fromMap(m)).toList();
  }

  Future<List<AttendanceRecord>> getRecordsForModule(String moduleId) async {
    final maps = await db.query(
      'attendance_records',
      where: 'module_id = ?',
      whereArgs: [moduleId],
      orderBy: 'timestamp DESC',
    );
    return maps.map((m) => AttendanceRecord.fromMap(m)).toList();
  }

  Future<Map<String, int>> getAttendanceCountsForModule(String moduleId) async {
    final attended = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM attendance_records WHERE module_id = ? AND is_attended = 1',
      [moduleId],
    )) ?? 0;

    final missed = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM attendance_records WHERE module_id = ? AND is_attended = 0',
      [moduleId],
    )) ?? 0;

    return {
      'attended': attended,
      'missed': missed,
      'total': attended + missed,
    };
  }

  Future<AttendanceRecord?> getLatestRecordForModule(String moduleId) async {
    final maps = await db.query(
      'attendance_records',
      where: 'module_id = ?',
      whereArgs: [moduleId],
      orderBy: 'timestamp DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return AttendanceRecord.fromMap(maps.first);
  }

  Future<void> recordAttendance(AttendanceRecord record) async {
    await db.insert('attendance_records', record.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateRecord(AttendanceRecord record) async {
    await db.update('attendance_records', record.toMap(), where: 'id = ?', whereArgs: [record.id]);
  }

  Future<void> deleteRecord(String id) async {
    await db.delete('attendance_records', where: 'id = ?', whereArgs: [id]);
  }
}
