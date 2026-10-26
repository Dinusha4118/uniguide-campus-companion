import 'dart:io';
import 'package:sqflite/sqflite.dart';
import '../../domain/models/module.dart';

class ModuleRepository {
  final Database db;

  ModuleRepository(this.db);

  Future<List<Module>> getAllModules() async {
    final maps = await db.query('modules', orderBy: 'code ASC');
    return maps.map((m) => Module.fromMap(m)).toList();
  }

  Future<Module?> getModuleById(String id) async {
    final maps = await db.query('modules', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Module.fromMap(maps.first);
  }

  Future<void> insertModule(Module module) async {
    await db.insert('modules', module.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateModule(Module module) async {
    await db.update('modules', module.toMap(), where: 'id = ?', whereArgs: [module.id]);
  }

  Future<Map<String, int>> getAffectedCounts(String moduleId) async {
    final classes = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM classes WHERE module_id = ?', [moduleId])) ?? 0;
    final attendance = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM attendance_records WHERE module_id = ?', [moduleId])) ?? 0;
    final deadlines = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM deadlines WHERE module_id = ?', [moduleId])) ?? 0;
    final studySessions = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM study_sessions WHERE module_id = ?', [moduleId])) ?? 0;
    final boardPhotos = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM board_photos WHERE module_id = ?', [moduleId])) ?? 0;

    return {
      'classes': classes,
      'attendance': attendance,
      'deadlines': deadlines,
      'studySessions': studySessions,
      'boardPhotos': boardPhotos,
    };
  }

  Future<void> deleteModule(String moduleId) async {
    // 1. Find photo files to delete from disk
    final photos = await db.query('board_photos', where: 'module_id = ?', whereArgs: [moduleId]);
    for (final p in photos) {
      final path = p['file_path'] as String?;
      if (path != null) {
        final f = File(path);
        if (await f.exists()) {
          try {
            await f.delete();
          } catch (_) {}
        }
      }
      final thumb = p['thumbnail_path'] as String?;
      if (thumb != null) {
        final f = File(thumb);
        if (await f.exists()) {
          try {
            await f.delete();
          } catch (_) {}
        }
      }
    }

    // 2. Delete module from database (foreign keys cascade to all tables)
    await db.delete('modules', where: 'id = ?', whereArgs: [moduleId]);
  }
}
