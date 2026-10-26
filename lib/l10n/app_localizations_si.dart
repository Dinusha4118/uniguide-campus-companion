// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Sinhala Sinhalese (`si`).
class AppLocalizationsSi extends AppLocalizations {
  AppLocalizationsSi([String locale = 'si']) : super(locale);

  @override
  String get appTitle => 'UniGuide';

  @override
  String get tagline => 'ඔබ සිටින තැන දැනගන්න. ඊළඟ පියවර සැලසුම් කරන්න.';

  @override
  String get disclaimer =>
      'නිල නොවන සිසු මෙවලමකි. නිල විශ්වවිද්‍යාල මූලාශ්‍ර වලින් සැමවිටම තහවුරු කරගන්න.';

  @override
  String get letsBegin => 'ආරම්භ කරමු';

  @override
  String get next => 'ඊළඟ';

  @override
  String get skip => 'මඟහරින්න';

  @override
  String get back => 'ආපසු';

  @override
  String get save => 'සුරකින්න';

  @override
  String get cancel => 'අවලංගු කරන්න';

  @override
  String get delete => 'මකන්න';

  @override
  String get confirm => 'තහවුරු කරන්න';

  @override
  String get edit => 'සංස්කරණය';

  @override
  String get done => 'සම්පූර්ණයි';

  @override
  String get undo => 'පෙර තත්වයට';

  @override
  String get tabHome => 'මුල් පිටුව';

  @override
  String get tabClasses => 'දේශන';

  @override
  String get tabDeadlines => 'නියමිත දින';

  @override
  String get tabStudy => 'අධ්‍යයනය';

  @override
  String get tabGpa => 'GPA';

  @override
  String get greetingMorning => 'සුබ උදෑසනක්';

  @override
  String get greetingAfternoon => 'සුබ දහවලක්';

  @override
  String get greetingEvening => 'සුබ සන්ධ්‍යාවක්';

  @override
  String get dayAtAGlance => 'ඔබේ දවස එක බැල්මකින්';

  @override
  String get nextClass => 'ඊළඟ දේශනය';

  @override
  String get inProgress => 'ක්‍රියාත්මක වෙමින් පවතී';

  @override
  String get viewTodayClasses => 'අද දේශන බලන්න';

  @override
  String get noClassesToday => 'අද දින දේශන සැලසුම් කර නැත';

  @override
  String get noTimetableConfigured => 'තවමත් කාල සටහනක් ඇතුළත් කර නැත';

  @override
  String get captureBoardNotes => 'ලෑල්ලේ සටහන් ඡායාරූප ගන්න';

  @override
  String get boardSnap => 'ලෑල්ලේ ඡායාරූප';

  @override
  String get settings => 'සැකසුම්';

  @override
  String get dueSoon => 'ළඟදීම නියමිත';

  @override
  String get attendanceAlert => 'පැමිණීම් අනතුරු ඇඟවීම';

  @override
  String get viewAllDeadlines => 'සියලු නියමිත දින බලන්න';

  @override
  String get viewAttendance => 'පැමිණීම බලන්න';

  @override
  String get timetableTitle => 'ඔබේ දේශන';

  @override
  String get segmentTimetable => 'කාල සටහන';

  @override
  String get segmentAttendance => 'පැමිණීම';

  @override
  String get addClass => 'දේශනයක් එක් කරන්න';

  @override
  String get editClass => 'දේශනය සංස්කරණය';

  @override
  String freeTimeForYou(String duration) {
    return 'ඔබට නිදහස් කාලය: $duration';
  }

  @override
  String get freeTimeSubtitle => 'විවේක ගැනීමට හෝ පාඩම් කිරීමට හොඳ කාලයකි';

  @override
  String get overlapWarning => 'අවවාදයයි: වෙනත් දේශනයක් සමඟ වේලාවන් ගැටේ';

  @override
  String get stayOnTrack => 'පැමිණීම නිවැරදිව තබාගන්න';

  @override
  String minAttendanceHeader(String percent) {
    return 'ඔබේ අවම පැමිණීම: $percent% · සැකසුම් මඟින් වෙනස් කරන්න';
  }

  @override
  String get attended => 'පැමිණියා';

  @override
  String get missed => 'නොපැමිණියා';

  @override
  String get safeStatus => 'ආරක්ෂිතයි';

  @override
  String get atLimitStatus => 'සීමාවේ පවතී';

  @override
  String get needsAttentionStatus => 'අවධානය අවශ්‍යයි';

  @override
  String get impossibleStatus => 'ළඟා විය නොහැක';

  @override
  String get noAttendanceRecorded => 'පැමිණීම් සටහන් කර නැත';

  @override
  String get deadlinesTitle => 'ඉදිරියෙන් සිටින්න';

  @override
  String get addDeadline => 'නියමිත දිනයක් එක් කරන්න';

  @override
  String get editDeadline => 'නියමිත දිනය සංස්කරණය';

  @override
  String get filterUpcoming => 'ඉදිරියට ඇති';

  @override
  String get filterOverdue => 'කල් ඉකුත් වූ';

  @override
  String get filterCompleted => 'සම්පූර්ණ කළ';

  @override
  String get swipeToCompleteHint =>
      'සම්පූර්ණ කළ බව දැක්වීමට දකුණට swipe කරන්න.';

  @override
  String get markAsDone => 'සම්පූර්ණ කළ බව සලකුණු කරන්න';

  @override
  String get restoreDeadline => 'නැවත සක්‍රිය කරන්න';

  @override
  String get noDeadlines => 'නියමිත දින කිසිවක් නැත!';

  @override
  String get gpaTitle => 'ඔබේ ඊළඟ ඉලක්කය';

  @override
  String get gpaSubtitle => 'විශ්වාසයෙන් යුතුව සැලසුම් කරන්න.';

  @override
  String get currentGpa => 'වත්මන් GPA අගය';

  @override
  String get targetGpa => 'ඉලක්කගත GPA අගය';

  @override
  String get exploreWhatIf => 'විය හැකි ශ්‍රේණි පරීක්ෂා කරන්න';

  @override
  String get editTargetAndCompleted => 'ඉලක්කය සහ අවසන් කළ ශ්‍රේණි සංස්කරණය';

  @override
  String get whatIfTitle => 'විය හැකි දේ සැලසුම්කරු';

  @override
  String get projectedGpa => 'අපේක්ෂිත GPA අගය';

  @override
  String get resetPlan => 'සැලැස්ම යළි පිහිටුවන්න';

  @override
  String get focusTitle => 'වරකට එක කාර්යයක්';

  @override
  String get focusSubtitle => 'සුළු අවධානයක් විශාල ජයග්‍රහණයක් ගෙන දෙයි.';

  @override
  String get startFocusing => 'අවධානය යොමු කිරීම අරඹන්න';

  @override
  String get pauseTimer => 'වෙලාව නවත්වන්න';

  @override
  String get resumeTimer => 'නැවත අරඹන්න';

  @override
  String get endSession => 'සැසිය අවසන් කරන්න';

  @override
  String get takeABreak => 'විනාඩි 5 ක විවේකයක් ගන්න';

  @override
  String get focusComplete => 'අවධානය යොමු කිරීමේ සැසිය අවසන්!';

  @override
  String get seeStudyStats => 'අධ්‍යයන ප්‍රගතිය බලන්න';

  @override
  String get studyStatsTitle => 'ඔබේ ප්‍රගතිය බලන්න';

  @override
  String get dailyFocusMinutes => 'දෛනික අවධානය · මිනිත්තු';

  @override
  String get byModule => 'විෂය අනුව';

  @override
  String dayStreak(int count) {
    return 'දින $count ක අඛණ්ඩතාව';
  }

  @override
  String get boardNotesTitle => 'ලෑල්ලේ සටහන්';

  @override
  String get boardNotesSubtitle => 'සියලු දේශන ඡායාරූප එකම තැනක.';

  @override
  String get captureBoard => 'ඡායාරූපයක් ගන්න';

  @override
  String get moduleFolder => 'විෂය ෆෝල්ඩරය';

  @override
  String get noPhotosYet => 'තවමත් ඡායාරූප නැත · පළමු සටහන ගන්න';

  @override
  String get deletePhotoConfirm => 'මෙම ඡායාරූපය මකා දමන්නද?';

  @override
  String get settingsTitle => 'ඔබට ගැලපෙන පරිදි සකසන්න';

  @override
  String get settingsSubtitle => 'සියලු දත්ත මෙම දුරකථනයේම පවතී.';

  @override
  String get settingLanguage => 'භාෂාව';

  @override
  String get settingAppearance => 'පෙනුම';

  @override
  String get settingAcademicRules => 'ශාස්ත්‍රීය නීති';

  @override
  String get settingReminders => 'මතක් කිරීම්';

  @override
  String get settingBackup => 'උපස්ථය (Backup)';

  @override
  String get settingModules => 'විෂයයන් කළමනාකරණය';

  @override
  String get exportBackup => 'උපස්ථය සුරකින්න (Export)';

  @override
  String get importBackup => 'උපස්ථය ආයාත කරන්න (Import)';

  @override
  String get backupExportSuccess => 'උපස්ථය සාර්ථකව නිර්මාණය විය';

  @override
  String get backupImportSuccess => 'උපස්ථය සාර්ථකව ප්‍රතිස්ථාපනය විය';

  @override
  String get backHome => 'මුල් පිටුවට';
}
