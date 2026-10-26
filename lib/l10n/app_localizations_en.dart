// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'UniGuide';

  @override
  String get tagline => 'Know where you stand. Plan what\'s next.';

  @override
  String get disclaimer =>
      'Unofficial student tool. Always confirm with official university sources.';

  @override
  String get letsBegin => 'Let\'s begin';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get back => 'Back';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get edit => 'Edit';

  @override
  String get done => 'Done';

  @override
  String get undo => 'Undo';

  @override
  String get tabHome => 'Home';

  @override
  String get tabClasses => 'Classes';

  @override
  String get tabDeadlines => 'Deadlines';

  @override
  String get tabStudy => 'Study';

  @override
  String get tabGpa => 'GPA';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get dayAtAGlance => 'Your day at a glance';

  @override
  String get nextClass => 'Next class';

  @override
  String get inProgress => 'In progress';

  @override
  String get viewTodayClasses => 'View today\'s classes';

  @override
  String get noClassesToday => 'No classes scheduled today';

  @override
  String get noTimetableConfigured => 'No timetable configured yet';

  @override
  String get captureBoardNotes => 'Capture board notes';

  @override
  String get boardSnap => 'Board Snap';

  @override
  String get settings => 'Settings';

  @override
  String get dueSoon => 'Due soon';

  @override
  String get attendanceAlert => 'Attendance alert';

  @override
  String get viewAllDeadlines => 'View all deadlines';

  @override
  String get viewAttendance => 'View attendance';

  @override
  String get timetableTitle => 'Your classes';

  @override
  String get segmentTimetable => 'Timetable';

  @override
  String get segmentAttendance => 'Attendance';

  @override
  String get addClass => 'Add class';

  @override
  String get editClass => 'Edit class';

  @override
  String freeTimeForYou(String duration) {
    return '$duration for you';
  }

  @override
  String get freeTimeSubtitle => 'A good time to recharge or review';

  @override
  String get overlapWarning => 'Warning: Overlaps with another scheduled class';

  @override
  String get stayOnTrack => 'Stay on track';

  @override
  String minAttendanceHeader(String percent) {
    return 'Your minimum attendance: $percent% · Edit in Settings';
  }

  @override
  String get attended => 'Attended';

  @override
  String get missed => 'Missed';

  @override
  String get safeStatus => 'Safe';

  @override
  String get atLimitStatus => 'At the limit';

  @override
  String get needsAttentionStatus => 'Needs attention';

  @override
  String get impossibleStatus => 'Cannot be reached';

  @override
  String get noAttendanceRecorded => 'No attendance recorded';

  @override
  String get deadlinesTitle => 'A little ahead';

  @override
  String get addDeadline => 'Add deadline';

  @override
  String get editDeadline => 'Edit deadline';

  @override
  String get filterUpcoming => 'Upcoming';

  @override
  String get filterOverdue => 'Overdue';

  @override
  String get filterCompleted => 'Completed';

  @override
  String get swipeToCompleteHint => 'Swipe right on a deadline to complete it.';

  @override
  String get markAsDone => 'Mark as done';

  @override
  String get restoreDeadline => 'Restore deadline';

  @override
  String get noDeadlines => 'No deadlines here!';

  @override
  String get gpaTitle => 'Your next milestone';

  @override
  String get gpaSubtitle => 'Plan with confidence.';

  @override
  String get currentGpa => 'Current GPA';

  @override
  String get targetGpa => 'Target GPA';

  @override
  String get exploreWhatIf => 'Explore what-if grades';

  @override
  String get editTargetAndCompleted => 'Edit target & completed grades';

  @override
  String get whatIfTitle => 'What-if planner';

  @override
  String get projectedGpa => 'Projected GPA';

  @override
  String get resetPlan => 'Reset plan';

  @override
  String get focusTitle => 'One thing at a time';

  @override
  String get focusSubtitle => 'A little focus goes a long way.';

  @override
  String get startFocusing => 'Start focusing';

  @override
  String get pauseTimer => 'Pause';

  @override
  String get resumeTimer => 'Resume';

  @override
  String get endSession => 'End session';

  @override
  String get takeABreak => 'Take a 5-min break';

  @override
  String get focusComplete => 'Focus session complete!';

  @override
  String get seeStudyStats => 'See your study stats';

  @override
  String get studyStatsTitle => 'See your progress';

  @override
  String get dailyFocusMinutes => 'Daily focus · minutes';

  @override
  String get byModule => 'By module';

  @override
  String dayStreak(int count) {
    return '$count-day streak';
  }

  @override
  String get boardNotesTitle => 'Your board notes';

  @override
  String get boardNotesSubtitle => 'All your lecture snapshots, together.';

  @override
  String get captureBoard => 'Capture a board';

  @override
  String get moduleFolder => 'Module folder';

  @override
  String get noPhotosYet => 'No photos yet · Capture your first note';

  @override
  String get deletePhotoConfirm => 'Delete this board photo?';

  @override
  String get settingsTitle => 'Make it work for you';

  @override
  String get settingsSubtitle => 'Everything stays on this phone.';

  @override
  String get settingLanguage => 'Language';

  @override
  String get settingAppearance => 'Appearance';

  @override
  String get settingAcademicRules => 'Academic rules';

  @override
  String get settingReminders => 'Reminders';

  @override
  String get settingBackup => 'Backup';

  @override
  String get settingModules => 'Modules';

  @override
  String get exportBackup => 'Export backup';

  @override
  String get importBackup => 'Import backup';

  @override
  String get backupExportSuccess => 'Backup exported successfully';

  @override
  String get backupImportSuccess => 'Backup restored successfully';

  @override
  String get backHome => 'Back home';
}
