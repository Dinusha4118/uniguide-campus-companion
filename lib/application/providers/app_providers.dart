import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/module_repository.dart';
import '../../data/repositories/timetable_repository.dart';
import '../../data/repositories/attendance_repository.dart';
import '../../data/repositories/deadline_repository.dart';
import '../../data/repositories/study_repository.dart';
import '../../data/repositories/board_photo_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/services/backup_service.dart';
import '../../data/services/notification_service.dart';
import '../../domain/models/module.dart';
import '../../domain/models/class_session.dart';
import '../../domain/models/attendance_record.dart';
import '../../domain/models/deadline.dart';
import '../../domain/models/study_session.dart';
import '../../domain/models/board_photo.dart';
import '../../domain/models/academic_settings.dart';
import '../../domain/calculations/gpa_calculator.dart';
import '../../domain/calculations/attendance_calculator.dart';
import '../../domain/calculations/timetable_calculator.dart';
import '../../domain/calculations/deadline_calculator.dart';
import '../../domain/calculations/study_calculator.dart';

// --- Database & Repository Providers ---
final databaseProvider = FutureProvider<Database>((ref) async {
  return await AppDatabase.database;
});

final moduleRepoProvider = Provider<ModuleRepository>((ref) {
  final db = ref.watch(databaseProvider).value;
  if (db == null) throw UnimplementedError('Database not initialized');
  return ModuleRepository(db);
});

final timetableRepoProvider = Provider<TimetableRepository>((ref) {
  final db = ref.watch(databaseProvider).value;
  if (db == null) throw UnimplementedError('Database not initialized');
  return TimetableRepository(db);
});

final attendanceRepoProvider = Provider<AttendanceRepository>((ref) {
  final db = ref.watch(databaseProvider).value;
  if (db == null) throw UnimplementedError('Database not initialized');
  return AttendanceRepository(db);
});

final deadlineRepoProvider = Provider<DeadlineRepository>((ref) {
  final db = ref.watch(databaseProvider).value;
  if (db == null) throw UnimplementedError('Database not initialized');
  return DeadlineRepository(db);
});

final studyRepoProvider = Provider<StudyRepository>((ref) {
  final db = ref.watch(databaseProvider).value;
  if (db == null) throw UnimplementedError('Database not initialized');
  return StudyRepository(db);
});

final boardPhotoRepoProvider = Provider<BoardPhotoRepository>((ref) {
  final db = ref.watch(databaseProvider).value;
  if (db == null) throw UnimplementedError('Database not initialized');
  return BoardPhotoRepository(db);
});

final settingsRepoProvider = Provider<SettingsRepository>((ref) {
  final db = ref.watch(databaseProvider).value;
  if (db == null) throw UnimplementedError('Database not initialized');
  return SettingsRepository(db);
});

final backupServiceProvider = Provider<BackupService>((ref) {
  final db = ref.watch(databaseProvider).value;
  if (db == null) throw UnimplementedError('Database not initialized');
  return BackupService(db);
});

// --- Settings & App State ---
class SettingsState {
  final String language; // 'en', 'si'
  final ThemeMode themeMode;
  final bool onboardingCompleted;
  final bool remindersEnabled;
  final AcademicSettings academicSettings;
  final String studentName;

  const SettingsState({
    required this.language,
    required this.themeMode,
    required this.onboardingCompleted,
    required this.remindersEnabled,
    required this.academicSettings,
    required this.studentName,
  });

  SettingsState copyWith({
    String? language,
    ThemeMode? themeMode,
    bool? onboardingCompleted,
    bool? remindersEnabled,
    AcademicSettings? academicSettings,
    String? studentName,
  }) {
    return SettingsState(
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      academicSettings: academicSettings ?? this.academicSettings,
      studentName: studentName ?? this.studentName,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SettingsRepository repo;

  SettingsNotifier(this.repo)
      : super(SettingsState(
          language: 'en',
          themeMode: ThemeMode.light,
          onboardingCompleted: false,
          remindersEnabled: true,
          academicSettings: AcademicSettings.initial(),
          studentName: 'Dinusha',
        )) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final lang = await repo.getString('language') ?? 'en';
    final themeStr = await repo.getString('appearance') ?? 'light';
    final onboarding = await repo.getBool('onboarding_completed', defaultValue: false);
    final reminders = await repo.getBool('reminders_enabled', defaultValue: true);
    final academic = await repo.getAcademicSettings();
    final name = await repo.getString('student_name') ?? 'Dinusha';

    ThemeMode mode;
    if (themeStr == 'dark') {
      mode = ThemeMode.dark;
    } else if (themeStr == 'system') {
      mode = ThemeMode.system;
    } else {
      mode = ThemeMode.light;
    }

    state = state.copyWith(
      language: lang,
      themeMode: mode,
      onboardingCompleted: onboarding,
      remindersEnabled: reminders,
      academicSettings: academic,
      studentName: name,
    );
  }

  Future<void> setLanguage(String lang) async {
    await repo.setString('language', lang);
    state = state.copyWith(language: lang);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    String modeStr = 'light';
    if (mode == ThemeMode.dark) modeStr = 'dark';
    if (mode == ThemeMode.system) modeStr = 'system';
    await repo.setString('appearance', modeStr);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    await repo.setBool('onboarding_completed', completed);
    state = state.copyWith(onboardingCompleted: completed);
  }

  Future<void> setRemindersEnabled(bool enabled) async {
    await repo.setBool('reminders_enabled', enabled);
    state = state.copyWith(remindersEnabled: enabled);
  }

  Future<void> saveAcademicSettings(AcademicSettings settings) async {
    await repo.saveAcademicSettings(settings);
    state = state.copyWith(academicSettings: settings);
  }

  Future<void> setStudentName(String name) async {
    await repo.setString('student_name', name);
    state = state.copyWith(studentName: name);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final repo = ref.watch(settingsRepoProvider);
  return SettingsNotifier(repo);
});

// --- Modules Provider ---
class ModulesNotifier extends StateNotifier<AsyncValue<List<Module>>> {
  final ModuleRepository repo;

  ModulesNotifier(this.repo) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    try {
      final list = await repo.getAllModules();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addModule(Module module) async {
    await repo.insertModule(module);
    await refresh();
  }

  Future<void> updateModule(Module module) async {
    await repo.updateModule(module);
    await refresh();
  }

  Future<Map<String, int>> getAffectedCounts(String id) async {
    return await repo.getAffectedCounts(id);
  }

  Future<void> deleteModule(String id) async {
    await repo.deleteModule(id);
    await refresh();
  }
}

final modulesProvider = StateNotifierProvider<ModulesNotifier, AsyncValue<List<Module>>>((ref) {
  final repo = ref.watch(moduleRepoProvider);
  return ModulesNotifier(repo);
});

// --- Timetable Provider ---
class TimetableNotifier extends StateNotifier<AsyncValue<List<ClassSession>>> {
  final TimetableRepository repo;

  TimetableNotifier(this.repo) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    try {
      final list = await repo.getAllClasses();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addClass(ClassSession session) async {
    await repo.insertClass(session);
    await refresh();
  }

  Future<void> updateClass(ClassSession session) async {
    await repo.updateClass(session);
    await refresh();
  }

  Future<void> deleteClass(String id) async {
    await repo.deleteClass(id);
    await refresh();
  }
}

final timetableProvider = StateNotifierProvider<TimetableNotifier, AsyncValue<List<ClassSession>>>((ref) {
  final repo = ref.watch(timetableRepoProvider);
  return TimetableNotifier(repo);
});

// --- Attendance Provider ---
class AttendanceNotifier extends StateNotifier<AsyncValue<List<AttendanceRecord>>> {
  final AttendanceRepository repo;

  AttendanceNotifier(this.repo) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    try {
      final list = await repo.getAllRecords();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> record({
    required String moduleId,
    required bool isAttended,
  }) async {
    final now = DateTime.now();
    final dateStr = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final rec = AttendanceRecord(
      id: '${moduleId}_${now.millisecondsSinceEpoch}',
      moduleId: moduleId,
      lectureDate: dateStr,
      isAttended: isAttended,
      timestamp: now,
    );
    await repo.recordAttendance(rec);
    await refresh();
  }

  Future<void> undo(String recordId) async {
    await repo.deleteRecord(recordId);
    await refresh();
  }
}

final attendanceProvider = StateNotifierProvider<AttendanceNotifier, AsyncValue<List<AttendanceRecord>>>((ref) {
  final repo = ref.watch(attendanceRepoProvider);
  return AttendanceNotifier(repo);
});

// --- Deadlines Provider ---
class DeadlinesNotifier extends StateNotifier<AsyncValue<List<Deadline>>> {
  final DeadlineRepository repo;
  final Ref ref;

  DeadlinesNotifier(this.repo, this.ref) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    try {
      final list = await repo.getAllDeadlines();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addDeadline(Deadline deadline) async {
    await repo.insertDeadline(deadline);
    final remindersOn = ref.read(settingsProvider).remindersEnabled;
    await NotificationService().scheduleDeadlineReminders(deadline, enabled: remindersOn);
    await refresh();
  }

  Future<void> updateDeadline(Deadline deadline) async {
    await repo.updateDeadline(deadline);
    final remindersOn = ref.read(settingsProvider).remindersEnabled;
    await NotificationService().scheduleDeadlineReminders(deadline, enabled: remindersOn);
    await refresh();
  }

  Future<void> toggleCompleted(String id, bool isCompleted) async {
    await repo.setCompleted(id, isCompleted);
    if (isCompleted) {
      await NotificationService().cancelDeadlineReminders(id);
    }
    await refresh();
  }

  Future<void> deleteDeadline(String id) async {
    await NotificationService().cancelDeadlineReminders(id);
    await repo.deleteDeadline(id);
    await refresh();
  }
}

final deadlinesProvider = StateNotifierProvider<DeadlinesNotifier, AsyncValue<List<Deadline>>>((ref) {
  final repo = ref.watch(deadlineRepoProvider);
  return DeadlinesNotifier(repo, ref);
});

// --- Focus Timer State ---
enum FocusTimerStatus { idle, running, paused, breakTime }

class FocusTimerState {
  final FocusTimerStatus status;
  final int remainingSeconds;
  final int totalSessionSeconds;
  final String? activeModuleId;
  final DateTime? sessionStartTime;

  const FocusTimerState({
    this.status = FocusTimerStatus.idle,
    this.remainingSeconds = 25 * 60,
    this.totalSessionSeconds = 25 * 60,
    this.activeModuleId,
    this.sessionStartTime,
  });

  FocusTimerState copyWith({
    FocusTimerStatus? status,
    int? remainingSeconds,
    int? totalSessionSeconds,
    String? activeModuleId,
    DateTime? sessionStartTime,
  }) {
    return FocusTimerState(
      status: status ?? this.status,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSessionSeconds: totalSessionSeconds ?? this.totalSessionSeconds,
      activeModuleId: activeModuleId ?? this.activeModuleId,
      sessionStartTime: sessionStartTime ?? this.sessionStartTime,
    );
  }
}

class FocusTimerNotifier extends StateNotifier<FocusTimerState> {
  final StudyRepository studyRepo;
  Timer? _timer;

  FocusTimerNotifier(this.studyRepo) : super(const FocusTimerState());

  void selectModule(String moduleId) {
    state = state.copyWith(activeModuleId: moduleId);
  }

  void startFocus({int minutes = 25}) {
    _timer?.cancel();
    state = state.copyWith(
      status: FocusTimerStatus.running,
      remainingSeconds: minutes * 60,
      totalSessionSeconds: minutes * 60,
      sessionStartTime: DateTime.now(),
    );
    _startTicker();
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(status: FocusTimerStatus.paused);
  }

  void resume() {
    state = state.copyWith(status: FocusTimerStatus.running);
    _startTicker();
  }

  Future<void> cancelSession() async {
    _timer?.cancel();
    state = state.copyWith(
      status: FocusTimerStatus.idle,
      remainingSeconds: 25 * 60,
      totalSessionSeconds: 25 * 60,
    );
  }

  Future<void> endAndSaveSession() async {
    _timer?.cancel();
    final elapsed = state.totalSessionSeconds - state.remainingSeconds;
    if (elapsed >= 60 && state.activeModuleId != null) {
      final session = StudySession(
        id: 'study_${DateTime.now().millisecondsSinceEpoch}',
        moduleId: state.activeModuleId!,
        durationSeconds: elapsed,
        timestamp: DateTime.now(),
        sessionType: 'focus',
      );
      await studyRepo.recordSession(session);
    }
    state = state.copyWith(
      status: FocusTimerStatus.idle,
      remainingSeconds: 25 * 60,
      totalSessionSeconds: 25 * 60,
    );
  }

  void startBreak({int minutes = 5}) {
    _timer?.cancel();
    state = state.copyWith(
      status: FocusTimerStatus.breakTime,
      remainingSeconds: minutes * 60,
      totalSessionSeconds: minutes * 60,
      sessionStartTime: DateTime.now(),
    );
    _startTicker();
  }

  void _startTicker() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (state.remainingSeconds > 1) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        _timer?.cancel();
        if (state.status == FocusTimerStatus.running) {
          // Completed focus session!
          if (state.activeModuleId != null) {
            final session = StudySession(
              id: 'study_${DateTime.now().millisecondsSinceEpoch}',
              moduleId: state.activeModuleId!,
              durationSeconds: state.totalSessionSeconds,
              timestamp: DateTime.now(),
              sessionType: 'focus',
            );
            await studyRepo.recordSession(session);
          }
          NotificationService().showInstantNotification(
            id: 8888,
            title: 'Focus Complete! 🎉',
            body: 'Great job! Time to take a restful 5-minute break.',
          );
          state = state.copyWith(
            status: FocusTimerStatus.idle,
            remainingSeconds: 25 * 60,
          );
        } else {
          // Break complete
          NotificationService().showInstantNotification(
            id: 8889,
            title: 'Break Finished',
            body: 'Ready for another productive session?',
          );
          state = state.copyWith(
            status: FocusTimerStatus.idle,
            remainingSeconds: 25 * 60,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final focusTimerProvider = StateNotifierProvider<FocusTimerNotifier, FocusTimerState>((ref) {
  final repo = ref.watch(studyRepoProvider);
  return FocusTimerNotifier(repo);
});

// --- Study Sessions List Provider ---
class StudySessionsNotifier extends StateNotifier<AsyncValue<List<StudySession>>> {
  final StudyRepository repo;

  StudySessionsNotifier(this.repo) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    try {
      final list = await repo.getAllSessions();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final studySessionsProvider = StateNotifierProvider<StudySessionsNotifier, AsyncValue<List<StudySession>>>((ref) {
  final repo = ref.watch(studyRepoProvider);
  return StudySessionsNotifier(repo);
});

// --- Board Photos Provider ---
class BoardPhotosNotifier extends StateNotifier<AsyncValue<List<BoardPhoto>>> {
  final BoardPhotoRepository repo;

  BoardPhotosNotifier(this.repo) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    try {
      final list = await repo.getAllPhotos();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addPhoto(BoardPhoto photo) async {
    await repo.insertPhoto(photo);
    await refresh();
  }

  Future<void> updateNote(String id, String note) async {
    await repo.updatePhotoNote(id, note);
    await refresh();
  }

  Future<void> deletePhoto(String id) async {
    await repo.deletePhoto(id);
    await refresh();
  }
}

final boardPhotosProvider = StateNotifierProvider<BoardPhotosNotifier, AsyncValue<List<BoardPhoto>>>((ref) {
  final repo = ref.watch(boardPhotoRepoProvider);
  return BoardPhotosNotifier(repo);
});
