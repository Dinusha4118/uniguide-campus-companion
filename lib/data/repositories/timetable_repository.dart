import 'package:sqflite/sqflite.dart';
import '../../domain/models/class_session.dart';

class TimetableRepository {
  final Database db;

  TimetableRepository(this.db);

  Future<List<ClassSession>> getAllClasses() async {
    final maps = await db.query('classes', orderBy: 'day_of_week ASC, start_time ASC');
    return maps.map((m) => ClassSession.fromMap(m)).toList();
  }

  Future<List<ClassSession>> getClassesForDay(int dayOfWeek) async {
    final maps = await db.query(
      'classes',
      where: 'day_of_week = ?',
      whereArgs: [dayOfWeek],
      orderBy: 'start_time ASC',
    );
    return maps.map((m) => ClassSession.fromMap(m)).toList();
  }

  Future<List<ClassSession>> getClassesForModule(String moduleId) async {
    final maps = await db.query('classes', where: 'module_id = ?', whereArgs: [moduleId]);
    return maps.map((m) => ClassSession.fromMap(m)).toList();
  }

  Future<void> insertClass(ClassSession session) async {
    await db.insert('classes', session.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateClass(ClassSession session) async {
    await db.update('classes', session.toMap(), where: 'id = ?', whereArgs: [session.id]);
  }

  Future<void> deleteClass(String id) async {
    await db.delete('classes', where: 'id = ?', whereArgs: [id]);
  }
}
