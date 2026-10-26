import 'package:sqflite/sqflite.dart';
import '../../domain/models/deadline.dart';

class DeadlineRepository {
  final Database db;

  DeadlineRepository(this.db);

  Future<List<Deadline>> getAllDeadlines() async {
    final maps = await db.query('deadlines', orderBy: 'due_datetime ASC');
    return maps.map((m) => Deadline.fromMap(m)).toList();
  }

  Future<Deadline?> getDeadlineById(String id) async {
    final maps = await db.query('deadlines', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Deadline.fromMap(maps.first);
  }

  Future<void> insertDeadline(Deadline deadline) async {
    await db.insert('deadlines', deadline.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateDeadline(Deadline deadline) async {
    await db.update('deadlines', deadline.toMap(), where: 'id = ?', whereArgs: [deadline.id]);
  }

  Future<void> setCompleted(String id, bool isCompleted) async {
    await db.update(
      'deadlines',
      {
        'is_completed': isCompleted ? 1 : 0,
        'completed_at': isCompleted ? DateTime.now().toIso8601String() : null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteDeadline(String id) async {
    await db.delete('deadlines', where: 'id = ?', whereArgs: [id]);
  }
}
