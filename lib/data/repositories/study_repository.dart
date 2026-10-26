import 'package:sqflite/sqflite.dart';
import '../../domain/models/study_session.dart';

class StudyRepository {
  final Database db;

  StudyRepository(this.db);

  Future<List<StudySession>> getAllSessions() async {
    final maps = await db.query('study_sessions', orderBy: 'timestamp DESC');
    return maps.map((m) => StudySession.fromMap(m)).toList();
  }

  Future<List<StudySession>> getSessionsForModule(String moduleId) async {
    final maps = await db.query(
      'study_sessions',
      where: 'module_id = ?',
      whereArgs: [moduleId],
      orderBy: 'timestamp DESC',
    );
    return maps.map((m) => StudySession.fromMap(m)).toList();
  }

  Future<void> recordSession(StudySession session) async {
    await db.insert('study_sessions', session.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteSession(String id) async {
    await db.delete('study_sessions', where: 'id = ?', whereArgs: [id]);
  }
}
