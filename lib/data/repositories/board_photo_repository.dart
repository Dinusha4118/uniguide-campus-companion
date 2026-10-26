import 'dart:io';
import 'package:sqflite/sqflite.dart';
import '../../domain/models/board_photo.dart';

class BoardPhotoRepository {
  final Database db;

  BoardPhotoRepository(this.db);

  Future<List<BoardPhoto>> getAllPhotos() async {
    final maps = await db.query('board_photos', orderBy: 'captured_date DESC');
    return maps.map((m) => BoardPhoto.fromMap(m)).toList();
  }

  Future<List<BoardPhoto>> getPhotosForModule(String moduleId) async {
    final maps = await db.query(
      'board_photos',
      where: 'module_id = ?',
      whereArgs: [moduleId],
      orderBy: 'captured_date DESC',
    );
    return maps.map((m) => BoardPhoto.fromMap(m)).toList();
  }

  Future<Map<String, int>> getPhotoCountsByModule() async {
    final rows = await db.rawQuery('''
      SELECT module_id, COUNT(*) as count 
      FROM board_photos 
      GROUP BY module_id
    ''');
    final result = <String, int>{};
    for (final r in rows) {
      final mId = r['module_id'] as String?;
      final count = (r['count'] as num?)?.toInt() ?? 0;
      if (mId != null) {
        result[mId] = count;
      }
    }
    return result;
  }

  Future<void> insertPhoto(BoardPhoto photo) async {
    await db.insert('board_photos', photo.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updatePhotoNote(String id, String note) async {
    await db.update('board_photos', {'note': note}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deletePhoto(String id) async {
    final rows = await db.query('board_photos', where: 'id = ?', whereArgs: [id]);
    if (rows.isNotEmpty) {
      final path = rows.first['file_path'] as String?;
      if (path != null) {
        final f = File(path);
        if (await f.exists()) {
          try {
            await f.delete();
          } catch (_) {}
        }
      }
      final thumb = rows.first['thumbnail_path'] as String?;
      if (thumb != null) {
        final f = File(thumb);
        if (await f.exists()) {
          try {
            await f.delete();
          } catch (_) {}
        }
      }
    }
    await db.delete('board_photos', where: 'id = ?', whereArgs: [id]);
  }
}
