import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const String _databaseName = 'campus_compass.db';
  static const int _databaseVersion = 1;

  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
      },
      onCreate: _onCreate,
    );
  }

  // Allow passing in-memory or custom database for testing
  static Future<Database> initInMemory() async {
    return await openDatabase(
      inMemoryDatabasePath,
      version: _databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
      },
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
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

    await db.execute('''
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

    await db.execute('''
      CREATE TABLE attendance_records (
        id TEXT PRIMARY KEY,
        module_id TEXT NOT NULL,
        lecture_date TEXT NOT NULL,
        is_attended INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (module_id) REFERENCES modules(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
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

    await db.execute('''
      CREATE TABLE study_sessions (
        id TEXT PRIMARY KEY,
        module_id TEXT NOT NULL,
        duration_seconds INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        session_type TEXT NOT NULL DEFAULT 'focus',
        FOREIGN KEY (module_id) REFERENCES modules(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
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

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      );
    ''');

    // Create helpful indices for performance on low-end devices
    await db.execute('CREATE INDEX idx_classes_day ON classes(day_of_week);');
    await db.execute('CREATE INDEX idx_attendance_module ON attendance_records(module_id);');
    await db.execute('CREATE INDEX idx_deadlines_due ON deadlines(due_datetime);');
    await db.execute('CREATE INDEX idx_study_timestamp ON study_sessions(timestamp);');
    await db.execute('CREATE INDEX idx_photos_module ON board_photos(module_id);');
  }

  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
