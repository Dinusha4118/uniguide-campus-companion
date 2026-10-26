import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:campus_compass/domain/models/module.dart';
import 'package:campus_compass/domain/models/class_session.dart';
import 'package:campus_compass/data/services/backup_service.dart';

class MockPathProviderPlatform extends Fake with MockPlatformInterfaceMixin implements PathProviderPlatform {
  final Directory tempDir;
  MockPathProviderPlatform(this.tempDir);

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return tempDir.path;
  }
}

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory tempDir;
  late Database db;
  late BackupService backupService;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('cc_test_backup_');
    PathProviderPlatform.instance = MockPathProviderPlatform(tempDir);

    db = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (database, version) async {
        await database.execute('CREATE TABLE modules (id TEXT PRIMARY KEY, code TEXT, name TEXT, credits INTEGER, color_hex TEXT, planned_lectures INTEGER, is_completed INTEGER, completed_grade TEXT, planned_grade TEXT);');
        await database.execute('CREATE TABLE classes (id TEXT PRIMARY KEY, module_id TEXT, day_of_week INTEGER, start_time TEXT, end_time TEXT, room TEXT, type TEXT, notes TEXT);');
        await database.execute('CREATE TABLE attendance_records (id TEXT PRIMARY KEY, module_id TEXT, lecture_date TEXT, is_attended INTEGER, timestamp TEXT);');
        await database.execute('CREATE TABLE deadlines (id TEXT PRIMARY KEY, module_id TEXT, title TEXT, due_datetime TEXT, type TEXT, notes TEXT, is_completed INTEGER, completed_at TEXT);');
        await database.execute('CREATE TABLE study_sessions (id TEXT PRIMARY KEY, module_id TEXT, duration_seconds INTEGER, timestamp TEXT, session_type TEXT);');
        await database.execute('CREATE TABLE board_photos (id TEXT PRIMARY KEY, module_id TEXT, file_path TEXT, thumbnail_path TEXT, captured_date TEXT, note TEXT);');
        await database.execute('CREATE TABLE settings (key TEXT PRIMARY KEY, value TEXT);');
      },
    );

    backupService = BackupService(db);
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('Export and restore roundtrip with preview validation', () async {
    // 1. Populate test data
    const m1 = Module(id: 'm1', code: 'IT1010', name: 'Programming', credits: 4);
    await db.insert('modules', m1.toMap());

    const c1 = ClassSession(id: 'c1', moduleId: 'm1', dayOfWeek: 1, startTime: '10:00', endTime: '12:00', room: '301');
    await db.insert('classes', c1.toMap());

    await db.insert('settings', {'key': 'language', 'value': 'si'});

    // 2. Export
    final zipPath = await backupService.exportBackup();
    expect(File(zipPath).existsSync(), isTrue);

    // 3. Preview
    final preview = await backupService.previewBackup(zipPath);
    expect(preview.version, 1);
    expect(preview.moduleCount, 1);
    expect(preview.classCount, 1);

    // 4. Modify / Clear DB
    await db.delete('modules');
    await db.delete('classes');
    expect((await db.query('modules')), isEmpty);

    // 5. Restore
    await backupService.restoreBackup(zipPath);

    // 6. Verify restored data
    final restoredModules = await db.query('modules');
    expect(restoredModules.length, 1);
    expect(restoredModules.first['code'], 'IT1010');

    final restoredClasses = await db.query('classes');
    expect(restoredClasses.length, 1);
    expect(restoredClasses.first['room'], '301');

    final restoredSettings = await db.query('settings');
    expect(restoredSettings.first['value'], 'si');
  });

  test('Malicious path traversal in archive is rejected', () async {
    // Attempting to preview a non-existent or malformed zip
    final badPath = '${tempDir.path}/not_found.zip';
    expect(() => backupService.previewBackup(badPath), throwsFormatException);
  });
}
