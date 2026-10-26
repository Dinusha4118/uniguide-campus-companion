import '../models/class_session.dart';

class NextClassResult {
  final ClassSession classSession;
  final Duration timeUntilStart;
  final bool isInProgress;
  final Duration remainingDuration;

  const NextClassResult({
    required this.classSession,
    required this.timeUntilStart,
    required this.isInProgress,
    required this.remainingDuration,
  });
}

class FreeTimeGap {
  final String start;
  final String end;
  final int durationMinutes;

  const FreeTimeGap({
    required this.start,
    required this.end,
    required this.durationMinutes,
  });

  String get formattedDuration {
    final hours = durationMinutes ~/ 60;
    final mins = durationMinutes % 60;
    if (hours > 0 && mins > 0) return '${hours}h ${mins}m';
    if (hours > 0) return '$hours ${hours == 1 ? 'hour' : 'hours'}';
    return '$mins min';
  }
}

class ClassOverlap {
  final ClassSession first;
  final ClassSession second;

  const ClassOverlap(this.first, this.second);
}

class TimetableCalculator {
  static NextClassResult? findNextClass(
    List<ClassSession> classes,
    DateTime now,
  ) {
    if (classes.isEmpty) return null;

    final currentDay = now.weekday; // 1 = Monday ... 7 = Sunday
    final currentMinutes = now.hour * 60 + now.minute;

    // 1. Check if any class is currently in progress today
    for (final session in classes) {
      if (session.dayOfWeek == currentDay) {
        if (currentMinutes >= session.startMinutes && currentMinutes < session.endMinutes) {
          final remMins = session.endMinutes - currentMinutes;
          return NextClassResult(
            classSession: session,
            timeUntilStart: Duration.zero,
            isInProgress: true,
            remainingDuration: Duration(minutes: remMins),
          );
        }
      }
    }

    // 2. Check future classes today
    ClassSession? nextToday;
    int minDiffToday = 999999;
    for (final session in classes) {
      if (session.dayOfWeek == currentDay && session.startMinutes > currentMinutes) {
        final diff = session.startMinutes - currentMinutes;
        if (diff < minDiffToday) {
          minDiffToday = diff;
          nextToday = session;
        }
      }
    }

    if (nextToday != null) {
      return NextClassResult(
        classSession: nextToday,
        timeUntilStart: Duration(minutes: minDiffToday),
        isInProgress: false,
        remainingDuration: Duration(minutes: nextToday.durationMinutes),
      );
    }

    // 3. Search upcoming days in week cycle (tomorrow through 6 days ahead)
    for (int dayOffset = 1; dayOffset <= 7; dayOffset++) {
      final targetDay = ((currentDay - 1 + dayOffset) % 7) + 1;
      final dayClasses = classes.where((c) => c.dayOfWeek == targetDay).toList()
        ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));

      if (dayClasses.isNotEmpty) {
        final nextSession = dayClasses.first;
        final minutesUntilMidnight = (24 * 60) - currentMinutes;
        final intermediateDaysMinutes = (dayOffset - 1) * 24 * 60;
        final totalMinutes = minutesUntilMidnight + intermediateDaysMinutes + nextSession.startMinutes;

        return NextClassResult(
          classSession: nextSession,
          timeUntilStart: Duration(minutes: totalMinutes),
          isInProgress: false,
          remainingDuration: Duration(minutes: nextSession.durationMinutes),
        );
      }
    }

    return null;
  }

  static List<FreeTimeGap> calculateFreeTimeGaps(List<ClassSession> classesForDay) {
    if (classesForDay.length < 2) return [];

    final sorted = List<ClassSession>.from(classesForDay)
      ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));

    final gaps = <FreeTimeGap>[];
    for (int i = 0; i < sorted.length - 1; i++) {
      final currentEnd = sorted[i].endMinutes;
      final nextStart = sorted[i + 1].startMinutes;
      if (nextStart > currentEnd) {
        final diff = nextStart - currentEnd;
        // Gaps of at least 15 minutes are meaningful for students
        if (diff >= 15) {
          gaps.add(FreeTimeGap(
            start: sorted[i].endTime,
            end: sorted[i + 1].startTime,
            durationMinutes: diff,
          ));
        }
      }
    }
    return gaps;
  }

  static List<ClassOverlap> detectOverlaps(List<ClassSession> classes) {
    final overlaps = <ClassOverlap>[];
    for (int d = 1; d <= 7; d++) {
      final dayClasses = classes.where((c) => c.dayOfWeek == d).toList();
      for (int i = 0; i < dayClasses.length; i++) {
        for (int j = i + 1; j < dayClasses.length; j++) {
          final a = dayClasses[i];
          final b = dayClasses[j];
          final hasOverlap = (a.startMinutes < b.endMinutes) && (b.startMinutes < a.endMinutes);
          if (hasOverlap) {
            overlaps.add(ClassOverlap(a, b));
          }
        }
      }
    }
    return overlaps;
  }
}
