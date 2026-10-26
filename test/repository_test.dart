import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:campus_compass/domain/models/module.dart';
import 'package:campus_compass/domain/models/class_session.dart';
import 'package:campus_compass/domain/models/attendance_record.dart';
import 'package:campus_compass/domain/models/deadline.dart';
import 'package:campus_compass/domain/models/study_session.dart';
import 'package:campus_compass/data/repositories/module_repository.dart';
import 'package:campus_compass/data/repositories/timetable_repository.dart';
import 'package:campus_compass/data/repositories/attendance_repository.dart';
import 'package:campus_compass/data/repositories/deadline_repository.dart';
import 'package:campus_compass/data/repositories/study_repository.dart';
import 'package:campus_compass/data/repositories/settings_repository.dart';

void main() {
  // Setup sqflite ffi for desktop/test runner
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late ModuleRepository moduleRepo;
  late TimetableRepository timetableRepo;
  late AttendanceRepository attendanceRepo;
  late DeadlineRepository deadlineRepo;
  late StudyRepository studyRepo;
  late SettingsRepository settingsRepo;

  setUp(() async {
    db = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON;');
      },
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE modules (
            id TEXT PRIMARY KEY,
            code TEXT NOT NULL,
            name TEXT NOT NULL,
            credits INTEGER NOT NULL,
            color_hex TEXT NOT NULL,
            planned_lectures INTEGER NOT NULL DEFAULT 12,
            is_completed INTEGER NOT NULL DEFAULT 0,
            completed_grade TEXT,
            planned_grade TEXT
          );
        ''');
        await database.execute('''
          CREATE TABLE classes (
            id TEXT PRIMARY KEY,
            module_id TEXT NOT NULL,
            day_of_week INTEGER NOT NULL,
            start_time TEXT NOT NULL,
            end_time TEXT NOT NULL,
            room TEXT NOT NULL,
            type TEXT NOT NULL DEFAULT 'Lecture',
            notes TEXT,
            FOREIGN KEY (module_id) REFERENCES modules(id) ON DELETE CASCADE
          );
        ''');
        await database.execute('''
          CREATE TABLE attendance_records (
            id TEXT PRIMARY KEY,
            module_id TEXT NOT NULL,
            lecture_date TEXT NOT NULL,
            is_attended INTEGER NOT NULL,
            timestamp TEXT NOT NULL,
            FOREIGN KEY (module_id) REFERENCES modules(id) ON DELETE CASCADE
          );
        ''');
        await database.execute('''
          CREATE TABLE deadlines (
            id TEXT PRIMARY KEY,
            module_id TEXT NOT NULL,
            title TEXT NOT NULL,
            due_datetime TEXT NOT NULL,
            type TEXT NOT NULL DEFAULT 'assignment',
            notes TEXT,
            is_completed INTEGER NOT NULL DEFAULT 0,
            completed_at TEXT,
            FOREIGN KEY (module_id) REFERENCES modules(id) ON DELETE CASCADE
          );
        ''');
        await database.execute('''
          CREATE TABLE study_sessions (
            id TEXT PRIMARY KEY,
            module_id TEXT NOT NULL,
            duration_seconds INTEGER NOT NULL,
            timestamp TEXT NOT NULL,
            session_type TEXT NOT NULL DEFAULT 'focus',
            FOREIGN KEY (module_id) REFERENCES modules(id) ON DELETE CASCADE
          );
        ''');
        await database.execute('''
          CREATE TABLE board_photos (
            id TEXT PRIMARY KEY,
            module_id TEXT NOT NULL,
            file_path TEXT NOT NULL,
            thumbnail_path TEXT,
            captured_date TEXT NOT NULL,
            note TEXT,
            FOREIGN KEY (module_id) REFERENCES modules(id) ON DELETE CASCADE
          );
        ''');
        await database.execute('''
          CREATE TABLE settings (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          );
        ''');
      },
    );

    moduleRepo = ModuleRepository(db);
    timetableRepo = TimetableRepository(db);
    attendanceRepo = AttendanceRepository(db);
    deadlineRepo = DeadlineRepository(db);
    studyRepo = StudyRepository(db);
    settingsRepo = SettingsRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('Module CRUD and queries', () async {
    const mod = Module(
      id: 'm1',
      code: 'IT1010',
      name: 'Programming',
      credits: 4,
      plannedLectures: 14,
    );
    await moduleRepo.insertModule(mod);

    final list = await moduleRepo.getAllModules();
    expect(list.length, 1);
    expect(list.first.code, 'IT1010');

    final fetched = await moduleRepo.getModuleById('m1');
    expect(fetched, isNotNull);
    expect(fetched!.credits, 4);

    final updated = mod.copyWith(name: 'Advanced Programming');
    await moduleRepo.updateModule(updated);
    final fetchedUpdated = await moduleRepo.getModuleById('m1');
    expect(fetchedUpdated!.name, 'Advanced Programming');
  });

  test('Cascade deletion cleans up linked classes, attendance, deadlines, and sessions', () async {
    const mod = Module(id: 'm1', code: 'IT1010', name: 'Programming', credits: 4);
    await moduleRepo.insertModule(mod);

    const cls = ClassSession(id: 'c1', moduleId: 'm1', dayOfWeek: 1, startTime: '10:00', endTime: '12:00', room: '301');
    await timetableRepo.insertClass(cls);

    final att = AttendanceRecord(id: 'a1', moduleId: 'm1', lectureDate: '2026-10-26', isAttended: true, timestamp: DateTime.now());
    await attendanceRepo.recordAttendance(att);

    final ddl = Deadline(id: 'd1', moduleId: 'm1', title: 'A1', dueDateTime: DateTime.now().add(const Duration(days: 2)));
    await deadlineRepo.insertDeadline(ddl);

    final session = StudySession(id: 's1', moduleId: 'm1', durationSeconds: 1500, timestamp: DateTime.now());
    await studyRepo.recordSession(session);

    // Verify affected counts before deletion
    final counts = await moduleRepo.getAffectedCounts('m1');
    expect(counts['classes'], 1);
    expect(counts['attendance'], 1);
    expect(counts['deadlines'], 1);
    expect(counts['studySessions'], 1);

    // Perform deletion
    await moduleRepo.deleteModule('m1');

    // Verify cascaded deletion
    expect(await moduleRepo.getAllModules(), isEmpty);
    expect(await timetableRepo.getAllClasses(), isEmpty);
    expect(await attendanceRepo.getAllRecords(), isEmpty);
    expect(await deadlineRepo.getAllDeadlines(), isEmpty);
    expect(await studyRepo.getAllSessions(), isEmpty);
  });

  test('Settings persistence and retrieval', () async {
    await settingsRepo.setString('language', 'si');
    await settingsRepo.setBool('onboarding_completed', true);

    expect(await settingsRepo.getString('language'), 'si');
    expect(await settingsRepo.getBool('onboarding_completed'), isTrue);
  });
}
