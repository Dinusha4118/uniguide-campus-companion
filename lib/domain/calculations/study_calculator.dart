import '../models/module.dart';
import '../models/study_session.dart';

class DailyStudyTotal {
  final int dayOfWeek; // 1 = Mon .. 7 = Sun
  final DateTime date;
  final int totalMinutes;

  const DailyStudyTotal({
    required this.dayOfWeek,
    required this.date,
    required this.totalMinutes,
  });
}

class ModuleStudyStat {
  final Module module;
  final int totalMinutes;

  const ModuleStudyStat({
    required this.module,
    required this.totalMinutes,
  });

  String get formattedTime {
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    if (hours > 0 && mins > 0) return '${hours}h ${mins}m';
    if (hours > 0) return '${hours}h';
    return '${mins}m';
  }
}

class StudySummary {
  final int totalMinutesWeek;
  final int streakDays;
  final int completedSessionsCount;
  final List<DailyStudyTotal> weeklyDailyTotals;
  final List<ModuleStudyStat> moduleStats;
  final List<Module> unstudiedModules;

  const StudySummary({
    required this.totalMinutesWeek,
    required this.streakDays,
    required this.completedSessionsCount,
    required this.weeklyDailyTotals,
    required this.moduleStats,
    required this.unstudiedModules,
  });

  String get formattedTotalTime {
    final hours = totalMinutesWeek ~/ 60;
    final mins = totalMinutesWeek % 60;
    if (hours > 0 && mins > 0) return '${hours}h ${mins}m';
    if (hours > 0) return '${hours}h';
    return '${mins}m';
  }
}

class StudyCalculator {
  static int calculateStreak(List<StudySession> sessions, DateTime today) {
    if (sessions.isEmpty) return 0;

    // Distinct calendar dates with at least one focus session
    final studyDates = <String>{};
    for (final s in sessions) {
      if (s.sessionType == 'focus' && s.durationSeconds >= 60) {
        final d = '${s.timestamp.year.toString().padLeft(4, '0')}-${s.timestamp.month.toString().padLeft(2, '0')}-${s.timestamp.day.toString().padLeft(2, '0')}';
        studyDates.add(d);
      }
    }

    if (studyDates.isEmpty) return 0;

    final todayDate = DateTime(today.year, today.month, today.day);
    final todayStr = '${todayDate.year.toString().padLeft(4, '0')}-${todayDate.month.toString().padLeft(2, '0')}-${todayDate.day.toString().padLeft(2, '0')}';
    final yesterdayDate = todayDate.subtract(const Duration(days: 1));
    final yesterdayStr = '${yesterdayDate.year.toString().padLeft(4, '0')}-${yesterdayDate.month.toString().padLeft(2, '0')}-${yesterdayDate.day.toString().padLeft(2, '0')}';

    // If student did not study today AND did not study yesterday, streak is broken
    DateTime checkDate;
    if (studyDates.contains(todayStr)) {
      checkDate = todayDate;
    } else if (studyDates.contains(yesterdayStr)) {
      checkDate = yesterdayDate;
    } else {
      return 0;
    }

    int streak = 0;
    while (true) {
      final str = '${checkDate.year.toString().padLeft(4, '0')}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
      if (studyDates.contains(str)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  static StudySummary calculateWeeklySummary({
    required List<StudySession> sessions,
    required List<Module> modules,
    required DateTime currentLocalTime,
  }) {
    // Determine Monday of current week
    final weekday = currentLocalTime.weekday; // 1 = Mon ... 7 = Sun
    final monday = DateTime(currentLocalTime.year, currentLocalTime.month, currentLocalTime.day)
        .subtract(Duration(days: weekday - 1));
    final sundayEnd = monday.add(const Duration(days: 7));

    final weekSessions = sessions.where((s) {
      return s.sessionType == 'focus' &&
          s.timestamp.isAfter(monday.subtract(const Duration(milliseconds: 1))) &&
          s.timestamp.isBefore(sundayEnd);
    }).toList();

    int totalMinutes = 0;
    for (final s in weekSessions) {
      totalMinutes += (s.durationSeconds ~/ 60);
    }

    // Daily totals Monday (1) to Sunday (7)
    final dailyTotals = <DailyStudyTotal>[];
    for (int i = 0; i < 7; i++) {
      final dayDate = monday.add(Duration(days: i));
      final daySessions = weekSessions.where((s) =>
          s.timestamp.year == dayDate.year &&
          s.timestamp.month == dayDate.month &&
          s.timestamp.day == dayDate.day);
      int dayMins = 0;
      for (final s in daySessions) {
        dayMins += (s.durationSeconds ~/ 60);
      }
      dailyTotals.add(DailyStudyTotal(
        dayOfWeek: i + 1,
        date: dayDate,
        totalMinutes: dayMins,
      ));
    }

    // Per module stats
    final moduleMinsMap = <String, int>{};
    for (final s in weekSessions) {
      moduleMinsMap[s.moduleId] = (moduleMinsMap[s.moduleId] ?? 0) + (s.durationSeconds ~/ 60);
    }

    final moduleStats = <ModuleStudyStat>[];
    final unstudiedModules = <Module>[];

    for (final m in modules) {
      final mins = moduleMinsMap[m.id] ?? 0;
      if (mins > 0) {
        moduleStats.add(ModuleStudyStat(module: m, totalMinutes: mins));
      } else {
        unstudiedModules.add(m);
      }
    }

    moduleStats.sort((a, b) => b.totalMinutes.compareTo(a.totalMinutes));

    final streak = calculateStreak(sessions, currentLocalTime);

    return StudySummary(
      totalMinutesWeek: totalMinutes,
      streakDays: streak,
      completedSessionsCount: weekSessions.length,
      weeklyDailyTotals: dailyTotals,
      moduleStats: moduleStats,
      unstudiedModules: unstudiedModules,
    );
  }
}
