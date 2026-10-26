import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../domain/models/module.dart';
import '../../domain/models/class_session.dart';
import '../../domain/models/attendance_record.dart';
import '../../domain/models/deadline.dart';
import '../../domain/models/study_session.dart';
import '../../domain/models/board_photo.dart';

class BackupPreview {
  final int version;
  final String exportedAt;
  final int moduleCount;
  final int classCount;
  final int attendanceCount;
  final int deadlineCount;
  final int sessionCount;
  final int photoCount;

  const BackupPreview({
    required this.version,
    required this.exportedAt,
    required this.moduleCount,
    required this.classCount,
    required this.attendanceCount,
    required this.deadlineCount,
    required this.sessionCount,
    required this.photoCount,
  });

  int get studySessionCount => sessionCount;
}

class BackupService {
  final Database db;

  BackupService(this.db);

  Future<String> exportBackup() async {
    final modules = (await db.query('modules')).map((m) => Module.fromMap(m).toMap()).toList();
    final classes = (await db.query('classes')).map((m) => ClassSession.fromMap(m).toMap()).toList();
    final attendance = (await db.query('attendance_records')).map((m) => AttendanceRecord.fromMap(m).toMap()).toList();
    final deadlines = (await db.query('deadlines')).map((m) => Deadline.fromMap(m).toMap()).toList();
    final sessions = (await db.query('study_sessions')).map((m) => StudySession.fromMap(m).toMap()).toList();
    final photos = (await db.query('board_photos')).map((m) => BoardPhoto.fromMap(m).toMap()).toList();
    final settings = await db.query('settings');

    final manifest = {
      'app': 'UniGuide',
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'modules': modules,
      'classes': classes,
      'attendance_records': attendance,
      'deadlines': deadlines,
      'study_sessions': sessions,
      'board_photos': photos,
      'settings': settings,
    };

    final jsonString = jsonEncode(manifest);
    final jsonBytes = utf8.encode(jsonString);

    final archive = Archive();
    archive.addFile(ArchiveFile('data.json', jsonBytes.length, jsonBytes));

    // Add board photos securely
    for (final photo in photos) {
      final filePath = photo['file_path'] as String?;
      if (filePath != null) {
        final file = File(filePath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final safeName = p.basename(filePath);
          archive.addFile(ArchiveFile('photos/$safeName', bytes.length, bytes));
        }
      }
    }

    final zipEncoder = ZipEncoder();
    final zipData = zipEncoder.encode(archive);

    final docsDir = await getApplicationDocumentsDirectory();
    final backupsDir = Directory(p.join(docsDir.path, 'backups'));
    if (!await backupsDir.exists()) {
      await backupsDir.create(recursive: true);
    }

    final filename = 'campus_compass_backup_${DateTime.now().millisecondsSinceEpoch}.zip';
    final backupFile = File(p.join(backupsDir.path, filename));
    await backupFile.writeAsBytes(zipData!);

    return backupFile.path;
  }

  Future<BackupPreview> previewBackup(String zipPath) async {
    final file = File(zipPath);
    if (!await file.exists()) {
      throw const FormatException('Selected backup file does not exist.');
    }

    // Safety check: protect against huge archives (> 250 MB)
    final length = await file.length();
    if (length > 250 * 1024 * 1024) {
      throw const FormatException('Archive file exceeds maximum allowed size (250MB).');
    }

    final bytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    // Verify path traversal security
    for (final entry in archive) {
      final name = entry.name;
      if (name.contains('..') || name.startsWith('/') || name.startsWith('\\')) {
        throw const FormatException('Security violation: malicious path detected in archive.');
      }
    }

    final dataEntry = archive.findFile('data.json');
    if (dataEntry == null) {
      throw const FormatException('Invalid backup: data.json not found in archive.');
    }

    final jsonString = utf8.decode(dataEntry.content as List<int>);
    final Map<String, dynamic> data;
    try {
      data = jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      throw const FormatException('Malformed data.json in backup archive.');
    }

    final appName = data['app'];
    if (appName != 'UniGuide' && appName != 'CampusCompass') {
      throw const FormatException('Incompatible backup file: not a UniGuide archive.');
    }

    final version = (data['version'] as num?)?.toInt() ?? 0;
    if (version < 1) {
      throw const FormatException('Unsupported backup version.');
    }

    final modules = (data['modules'] as List?)?.length ?? 0;
    final classes = (data['classes'] as List?)?.length ?? 0;
    final attendance = (data['attendance_records'] as List?)?.length ?? 0;
    final deadlines = (data['deadlines'] as List?)?.length ?? 0;
    final sessions = (data['study_sessions'] as List?)?.length ?? 0;
    final photos = (data['board_photos'] as List?)?.length ?? 0;

    return BackupPreview(
      version: version,
      exportedAt: (data['exported_at'] as String?) ?? 'Unknown',
      moduleCount: modules,
      classCount: classes,
      attendanceCount: attendance,
      deadlineCount: deadlines,
      sessionCount: sessions,
      photoCount: photos,
    );
  }

  Future<void> restoreBackup(String zipPath) async {
    final preview = await previewBackup(zipPath); // validates archive safely
    final bytes = await File(zipPath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    final dataEntry = archive.findFile('data.json')!;
    final jsonString = utf8.decode(dataEntry.content as List<int>);
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    final docsDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(docsDir.path, 'board_photos'));
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    // Extract photo files safely into app private storage
    final photoPathMapping = <String, String>{}; // old basename -> new local path
    for (final entry in archive) {
      if (entry.isFile && entry.name.startsWith('photos/')) {
        final safeBaseName = p.basename(entry.name);
        final targetPath = p.join(photosDir.path, safeBaseName);
        await File(targetPath).writeAsBytes(entry.content as List<int>);
        photoPathMapping[safeBaseName] = targetPath;
      }
    }

    // Perform atomic transaction
    await db.transaction((txn) async {
      // Clear current data in reverse dependency order
      await txn.delete('board_photos');
      await txn.delete('study_sessions');
      await txn.delete('deadlines');
      await txn.delete('attendance_records');
      await txn.delete('classes');
      await txn.delete('modules');
      await txn.delete('settings');

      // Insert restored data
      final modules = (data['modules'] as List? ?? []);
      for (final m in modules) {
        await txn.insert('modules', m as Map<String, dynamic>, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      final classes = (data['classes'] as List? ?? []);
      for (final c in classes) {
        await txn.insert('classes', c as Map<String, dynamic>, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      final attendance = (data['attendance_records'] as List? ?? []);
      for (final a in attendance) {
        await txn.insert('attendance_records', a as Map<String, dynamic>, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      final deadlines = (data['deadlines'] as List? ?? []);
      for (final d in deadlines) {
        await txn.insert('deadlines', d as Map<String, dynamic>, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      final sessions = (data['study_sessions'] as List? ?? []);
      for (final s in sessions) {
        await txn.insert('study_sessions', s as Map<String, dynamic>, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      final photos = (data['board_photos'] as List? ?? []);
      for (final ph in photos) {
        final map = Map<String, dynamic>.from(ph as Map<String, dynamic>);
        final oldPath = map['file_path'] as String?;
        if (oldPath != null) {
          final base = p.basename(oldPath);
          final newPath = photoPathMapping[base] ?? p.join(photosDir.path, base);
          map['file_path'] = newPath;
        }
        await txn.insert('board_photos', map, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      final settings = (data['settings'] as List? ?? []);
      for (final st in settings) {
        await txn.insert('settings', st as Map<String, dynamic>, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }
}
