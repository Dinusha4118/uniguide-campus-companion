import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'dart:io';

import 'package:campus_compass/main.dart';
import 'package:campus_compass/application/providers/app_providers.dart';
import 'package:campus_compass/domain/models/module.dart';
import 'package:campus_compass/domain/models/class_session.dart';
import 'package:campus_compass/domain/models/deadline.dart';
import 'package:campus_compass/domain/models/academic_settings.dart';

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

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('cc_widget_flow_');
    PathProviderPlatform.instance = MockPathProviderPlatform(tempDir);

    db = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
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
            type TEXT,
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
            type TEXT NOT NULL,
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
            session_type TEXT NOT NULL,
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

    // Seed dummy module for verification
    await db.insert('modules', const Module(
      id: 'mod_1',
      code: 'IT2030',
      name: 'Computer Networks',
      credits: 4,
      plannedLectures: 12,
    ).toMap());
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  testWidgets('App launches with ProviderScope and renders UniGuideApp', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWith((ref) => db),
        ],
        child: const UniGuideApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify app renders branding and tagline on splash
    expect(find.text('Uni'), findsOneWidget);
    expect(find.text('Guide'), findsOneWidget);
    expect(find.textContaining('Know where you stand'), findsOneWidget);
  });
}
