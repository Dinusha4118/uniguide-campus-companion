import 'package:flutter_test/flutter_test.dart';
import 'package:campus_compass/domain/models/module.dart';
import 'package:campus_compass/domain/models/class_session.dart';
import 'package:campus_compass/domain/models/study_session.dart';
import 'package:campus_compass/domain/models/academic_settings.dart';
import 'package:campus_compass/domain/calculations/gpa_calculator.dart';
import 'package:campus_compass/domain/calculations/attendance_calculator.dart';
import 'package:campus_compass/domain/calculations/timetable_calculator.dart';
import 'package:campus_compass/domain/calculations/deadline_calculator.dart';
import 'package:campus_compass/domain/calculations/study_calculator.dart';

void main() {
  final scale = AcademicSettings.defaultSliitGradeScale;

  group('GPA Calculations (12 cases)', () {
    test('1. Empty completed modules produces 0.0 GPA', () {
      final res = GpaCalculator.calculateCurrentGpa([], scale);
      expect(res.currentGpa, 0.0);
      expect(res.completedCredits, 0);
    });

    test('2. Single module GPA calculation', () {
      final mods = [
        const Module(id: '1', code: 'IT1010', name: 'IP', credits: 4, isCompleted: true, completedGrade: 'A'),
      ];
      final res = GpaCalculator.calculateCurrentGpa(mods, scale);
      expect(res.currentGpa, 4.0);
      expect(res.completedCredits, 4);
    });

    test('3. Weighted average calculation with varying credits', () {
      final mods = [
        const Module(id: '1', code: 'IT1010', name: 'IP', credits: 4, isCompleted: true, completedGrade: 'A'), // 4*4.0 = 16
        const Module(id: '2', code: 'IT1020', name: 'MC', credits: 2, isCompleted: true, completedGrade: 'B'), // 2*3.0 = 6
      ]; // (16 + 6) / 6 = 22 / 6 = 3.6666...
      final res = GpaCalculator.calculateCurrentGpa(mods, scale);
      expect(res.completedCredits, 6);
      expect(res.currentGpa, closeTo(3.666, 0.001));
    });

    test('4. Modules with null completedGrade or isCompleted=false are ignored', () {
      final mods = [
        const Module(id: '1', code: 'IT1010', name: 'IP', credits: 4, isCompleted: true, completedGrade: 'A'),
        const Module(id: '2', code: 'IT1020', name: 'MC', credits: 4, isCompleted: false, completedGrade: null),
        const Module(id: '3', code: 'IT1030', name: 'DSA', credits: 4, isCompleted: true, completedGrade: null),
      ];
      final res = GpaCalculator.calculateCurrentGpa(mods, scale);
      expect(res.completedCredits, 4);
      expect(res.currentGpa, 4.0);
    });

    test('5. BRD Example: Current GPA 3.00 on 30 credits, target 3.30 with 30 remaining requires 3.60', () {
      final res = GpaCalculator.calculateRequiredRemainingAverage(
        completedCredits: 30,
        completedPoints: 90.0, // 30 * 3.00
        remainingCredits: 30,
        targetGpa: 3.30,
        gradeScale: scale,
      );
      expect(res.status, TargetFeasibilityStatus.achievable);
      expect(res.requiredAverage, closeTo(3.60, 0.001));
    });

    test('6. Target already achieved without remaining points', () {
      final res = GpaCalculator.calculateRequiredRemainingAverage(
        completedCredits: 30,
        completedPoints: 110.0, // 3.66 GPA
        remainingCredits: 30,
        targetGpa: 1.50,
        gradeScale: scale,
      );
      expect(res.status, TargetFeasibilityStatus.alreadyAchieved);
    });

    test('7. Target mathematically impossible (exceeds max scale 4.0)', () {
      final res = GpaCalculator.calculateRequiredRemainingAverage(
        completedCredits: 30,
        completedPoints: 60.0, // 2.0 GPA
        remainingCredits: 10,
        targetGpa: 3.80, // (3.8 * 40 - 60) / 10 = (152 - 60)/10 = 9.2 > 4.0
        gradeScale: scale,
      );
      expect(res.status, TargetFeasibilityStatus.impossibleTooHigh);
      expect(res.requiredAverage! > 4.0, isTrue);
    });

    test('8. Target with zero remaining credits when target already met', () {
      final res = GpaCalculator.calculateRequiredRemainingAverage(
        completedCredits: 30,
        completedPoints: 99.0, // 3.30 GPA
        remainingCredits: 0,
        targetGpa: 3.30,
        gradeScale: scale,
      );
      expect(res.status, TargetFeasibilityStatus.alreadyAchieved);
    });

    test('9. Target with zero remaining credits when target not met', () {
      final res = GpaCalculator.calculateRequiredRemainingAverage(
        completedCredits: 30,
        completedPoints: 90.0, // 3.00 GPA
        remainingCredits: 0,
        targetGpa: 3.50,
        gradeScale: scale,
      );
      expect(res.status, TargetFeasibilityStatus.noRemainingCredits);
    });

    test('10. Invalid target below 0.0 or above 4.0', () {
      final res = GpaCalculator.calculateRequiredRemainingAverage(
        completedCredits: 30,
        completedPoints: 90.0,
        remainingCredits: 30,
        targetGpa: 4.50,
        gradeScale: scale,
      );
      expect(res.status, TargetFeasibilityStatus.invalidTarget);
    });

    test('11. What-If projected GPA calculates exact weighted average of completed + planned', () {
      final completed = [
        const Module(id: '1', code: 'M1', name: 'M1', credits: 4, isCompleted: true, completedGrade: 'A'), // 16
      ];
      final remaining = [
        const Module(id: '2', code: 'M2', name: 'M2', credits: 4, isCompleted: false),
      ];
      final planned = {'2': 'B'}; // 4 * 3.0 = 12

      final projected = GpaCalculator.calculateProjectedGpa(
        completedModules: completed,
        remainingModules: remaining,
        plannedGrades: planned,
        gradeScale: scale,
      );
      // (16 + 12) / 8 = 28 / 8 = 3.50
      expect(projected, closeTo(3.50, 0.001));
    });

    test('12. What-If handles unselected planned grades without crashing', () {
      final completed = [
        const Module(id: '1', code: 'M1', name: 'M1', credits: 4, isCompleted: true, completedGrade: 'A'),
      ];
      final remaining = [
        const Module(id: '2', code: 'M2', name: 'M2', credits: 4, isCompleted: false),
      ];
      final projected = GpaCalculator.calculateProjectedGpa(
        completedModules: completed,
        remainingModules: remaining,
        plannedGrades: {}, // no selection
        gradeScale: scale,
      );
      expect(projected, 4.0);
    });
  });

  group('Attendance Safe-Skip Calculations (10 cases)', () {
    test('13. BRD Example: 12 planned, 80% req -> required 10, max misses 2. With 1 missed, 1 safe miss remains', () {
      final res = AttendanceCalculator.calculateSafeSkips(
        attended: 0,
        missed: 1,
        plannedLectures: 12,
        minAttendanceFraction: 0.80,
      );
      expect(res.requiredAttended, 10);
      expect(res.maximumAllowedMisses, 2);
      expect(res.safeAdditionalMisses, 1);
      expect(res.isFeasible, isTrue);
    });

    test('14. Perfect attendance allows full maximumAllowedMisses', () {
      final res = AttendanceCalculator.calculateSafeSkips(
        attended: 5,
        missed: 0,
        plannedLectures: 12,
        minAttendanceFraction: 0.80,
      );
      expect(res.safeAdditionalMisses, 2);
      expect(res.status, AttendanceStatus.safe);
    });

    test('15. Exactly at the limit: 2 missed out of 2 allowed leaves 0 safe misses', () {
      final res = AttendanceCalculator.calculateSafeSkips(
        attended: 8,
        missed: 2,
        plannedLectures: 12,
        minAttendanceFraction: 0.80,
      );
      expect(res.safeAdditionalMisses, 0);
      expect(res.isFeasible, isTrue);
      expect(res.status, AttendanceStatus.atLimit);
    });

    test('16. Target impossible when missed exceeds maximumAllowedMisses', () {
      final res = AttendanceCalculator.calculateSafeSkips(
        attended: 7,
        missed: 3, // 3 missed -> only 9 can be attended, but 10 required
        plannedLectures: 12,
        minAttendanceFraction: 0.80,
      );
      expect(res.isFeasible, isFalse);
      expect(res.status, AttendanceStatus.impossible);
    });

    test('17. Empty attendance history displays no records', () {
      final res = AttendanceCalculator.calculateSafeSkips(
        attended: 0,
        missed: 0,
        plannedLectures: 12,
        minAttendanceFraction: 0.80,
      );
      expect(res.currentPercentage, isNull);
      expect(res.status, AttendanceStatus.noRecords);
    });

    test('18. Zero or unentered planned lectures warns user to configure plan', () {
      final res = AttendanceCalculator.calculateSafeSkips(
        attended: 4,
        missed: 1,
        plannedLectures: 0,
      );
      expect(res.plannedLectures, 0);
      expect(res.currentPercentage, 80.0);
      expect(res.descriptionText, contains('Set planned lectures'));
    });

    test('19. Safe skips cannot exceed remaining lectures', () {
      // 10 planned, 80% requires 8, allowed misses = 2.
      // Already attended 8, missed 1 -> total 9 recorded. Remaining = 1.
      // Max misses left = 2 - 1 = 1. Safe skips = min(1, 1) = 1.
      final res = AttendanceCalculator.calculateSafeSkips(
        attended: 8,
        missed: 1,
        plannedLectures: 10,
        minAttendanceFraction: 0.80,
      );
      expect(res.remainingLectures, 1);
      expect(res.safeAdditionalMisses, 1);
    });

    test('20. Ceiling rounding on non-integer required lectures (e.g. 15 lectures at 80% = 12)', () {
      final res = AttendanceCalculator.calculateSafeSkips(
        attended: 10,
        missed: 2,
        plannedLectures: 15,
        minAttendanceFraction: 0.80,
      );
      expect(res.requiredAttended, 12);
      expect(res.maximumAllowedMisses, 3);
      expect(res.safeAdditionalMisses, 1);
    });

    test('21. Custom threshold (e.g. 75% attendance rule)', () {
      // 16 lectures at 75% = 12 required attended, 4 max misses.
      final res = AttendanceCalculator.calculateSafeSkips(
        attended: 6,
        missed: 2,
        plannedLectures: 16,
        minAttendanceFraction: 0.75,
      );
      expect(res.requiredAttended, 12);
      expect(res.maximumAllowedMisses, 4);
      expect(res.safeAdditionalMisses, 2);
    });

    test('22. Needs attention state when percentage currently below threshold but still feasible', () {
      // 12 planned, 80% req (10 needed). Currently 2 attended, 1 missed (66.7%).
      // Remaining = 9. 2 + 9 = 11 >= 10 (feasible).
      final res = AttendanceCalculator.calculateSafeSkips(
        attended: 2,
        missed: 1,
        plannedLectures: 12,
        minAttendanceFraction: 0.80,
      );
      expect(res.isFeasible, isTrue);
      expect(res.status, AttendanceStatus.needsAttention);
    });
  });

  group('Timetable & Class Calculation Tests', () {
    final classes = [
      const ClassSession(
        id: 'c1',
        moduleId: 'm1',
        dayOfWeek: 1, // Monday
        startTime: '10:30',
        endTime: '12:30',
        room: 'Hall 301',
      ),
      const ClassSession(
        id: 'c2',
        moduleId: 'm2',
        dayOfWeek: 1, // Monday
        startTime: '14:30',
        endTime: '16:30',
        room: 'Lab 3',
      ),
      const ClassSession(
        id: 'c3',
        moduleId: 'm3',
        dayOfWeek: 3, // Wednesday
        startTime: '09:00',
        endTime: '11:00',
        room: 'Hall 202',
      ),
    ];

    test('23. BRD Dilani Example: At 11:30 AM during class 1, reports class in progress', () {
      final monday1130 = DateTime(2026, 10, 26, 11, 30); // 2026-10-26 is Monday
      final res = TimetableCalculator.findNextClass(classes, monday1130);
      expect(res, isNotNull);
      expect(res!.classSession.id, 'c1');
      expect(res.isInProgress, isTrue);
      expect(res.remainingDuration.inMinutes, 60);
    });

    test('24. At 12:45 PM between classes, reports next class is Lab 3 in 105 min', () {
      final monday1245 = DateTime(2026, 10, 26, 12, 45);
      final res = TimetableCalculator.findNextClass(classes, monday1245);
      expect(res, isNotNull);
      expect(res!.classSession.id, 'c2');
      expect(res.isInProgress, isFalse);
      expect(res.timeUntilStart.inMinutes, 105);
    });

    test('25. Free time gaps: 12:30 to 14:30 detected as 2 hours for you', () {
      final mondayClasses = classes.where((c) => c.dayOfWeek == 1).toList();
      final gaps = TimetableCalculator.calculateFreeTimeGaps(mondayClasses);
      expect(gaps.length, 1);
      expect(gaps.first.durationMinutes, 120);
      expect(gaps.first.formattedDuration, '2 hours');
    });

    test('26. Overlap detection finds overlapping classes on same day', () {
      final overlappingList = [
        const ClassSession(id: '1', moduleId: 'm1', dayOfWeek: 2, startTime: '09:00', endTime: '11:00', room: 'R1'),
        const ClassSession(id: '2', moduleId: 'm2', dayOfWeek: 2, startTime: '10:00', endTime: '12:00', room: 'R2'),
      ];
      final overlaps = TimetableCalculator.detectOverlaps(overlappingList);
      expect(overlaps.length, 1);
    });
  });

  group('Deadline Urgency & Sorting Tests', () {
    final now = DateTime(2026, 10, 25, 12, 0);

    test('27. Deadlines under 48 hours are urgentUnder2Days', () {
      final d = now.add(const Duration(hours: 30));
      expect(DeadlineCalculator.getUrgency(d, now), DeadlineUrgency.urgentUnder2Days);
      expect(DeadlineCalculator.formatCountdown(d, now), '1 day left');
    });

    test('28. Deadlines under 7 days are warningUnder7Days', () {
      final d = now.add(const Duration(days: 4));
      expect(DeadlineCalculator.getUrgency(d, now), DeadlineUrgency.warningUnder7Days);
      expect(DeadlineCalculator.formatCountdown(d, now), '4 days left');
    });

    test('29. Overdue deadlines are correctly detected', () {
      final d = now.subtract(const Duration(hours: 5));
      expect(DeadlineCalculator.getUrgency(d, now), DeadlineUrgency.overdue);
      expect(DeadlineCalculator.formatCountdown(d, now), 'Overdue by 5 hours');
    });
  });

  group('Study Streak Tests', () {
    final today = DateTime(2026, 10, 25, 14, 0);

    test('30. Consecutive daily focus sessions increment streak', () {
      final sessions = [
        StudySession(id: '1', moduleId: 'm1', durationSeconds: 1500, timestamp: DateTime(2026, 10, 25, 10, 0)),
        StudySession(id: '2', moduleId: 'm1', durationSeconds: 1500, timestamp: DateTime(2026, 10, 24, 10, 0)),
        StudySession(id: '3', moduleId: 'm1', durationSeconds: 1500, timestamp: DateTime(2026, 10, 23, 10, 0)),
      ];
      final streak = StudyCalculator.calculateStreak(sessions, today);
      expect(streak, 3);
    });

    test('31. Streak preserved if user has not yet studied today but studied yesterday', () {
      final sessions = [
        StudySession(id: '1', moduleId: 'm1', durationSeconds: 1500, timestamp: DateTime(2026, 10, 24, 10, 0)),
        StudySession(id: '2', moduleId: 'm1', durationSeconds: 1500, timestamp: DateTime(2026, 10, 23, 10, 0)),
      ];
      final streak = StudyCalculator.calculateStreak(sessions, today);
      expect(streak, 2);
    });

    test('32. Gap of 2 or more days resets streak to 0', () {
      final sessions = [
        StudySession(id: '1', moduleId: 'm1', durationSeconds: 1500, timestamp: DateTime(2026, 10, 22, 10, 0)),
      ];
      final streak = StudyCalculator.calculateStreak(sessions, today);
      expect(streak, 0);
    });
  });
}
