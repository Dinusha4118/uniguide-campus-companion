import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('si'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'UniGuide'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Know where you stand. Plan what\'s next.'**
  String get tagline;

  /// No description provided for @disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Unofficial student tool. Always confirm with official university sources.'**
  String get disclaimer;

  /// No description provided for @letsBegin.
  ///
  /// In en, this message translates to:
  /// **'Let\'s begin'**
  String get letsBegin;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabClasses.
  ///
  /// In en, this message translates to:
  /// **'Classes'**
  String get tabClasses;

  /// No description provided for @tabDeadlines.
  ///
  /// In en, this message translates to:
  /// **'Deadlines'**
  String get tabDeadlines;

  /// No description provided for @tabStudy.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get tabStudy;

  /// No description provided for @tabGpa.
  ///
  /// In en, this message translates to:
  /// **'GPA'**
  String get tabGpa;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @dayAtAGlance.
  ///
  /// In en, this message translates to:
  /// **'Your day at a glance'**
  String get dayAtAGlance;

  /// No description provided for @nextClass.
  ///
  /// In en, this message translates to:
  /// **'Next class'**
  String get nextClass;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgress;

  /// No description provided for @viewTodayClasses.
  ///
  /// In en, this message translates to:
  /// **'View today\'s classes'**
  String get viewTodayClasses;

  /// No description provided for @noClassesToday.
  ///
  /// In en, this message translates to:
  /// **'No classes scheduled today'**
  String get noClassesToday;

  /// No description provided for @noTimetableConfigured.
  ///
  /// In en, this message translates to:
  /// **'No timetable configured yet'**
  String get noTimetableConfigured;

  /// No description provided for @captureBoardNotes.
  ///
  /// In en, this message translates to:
  /// **'Capture board notes'**
  String get captureBoardNotes;

  /// No description provided for @boardSnap.
  ///
  /// In en, this message translates to:
  /// **'Board Snap'**
  String get boardSnap;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @dueSoon.
  ///
  /// In en, this message translates to:
  /// **'Due soon'**
  String get dueSoon;

  /// No description provided for @attendanceAlert.
  ///
  /// In en, this message translates to:
  /// **'Attendance alert'**
  String get attendanceAlert;

  /// No description provided for @viewAllDeadlines.
  ///
  /// In en, this message translates to:
  /// **'View all deadlines'**
  String get viewAllDeadlines;

  /// No description provided for @viewAttendance.
  ///
  /// In en, this message translates to:
  /// **'View attendance'**
  String get viewAttendance;

  /// No description provided for @timetableTitle.
  ///
  /// In en, this message translates to:
  /// **'Your classes'**
  String get timetableTitle;

  /// No description provided for @segmentTimetable.
  ///
  /// In en, this message translates to:
  /// **'Timetable'**
  String get segmentTimetable;

  /// No description provided for @segmentAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get segmentAttendance;

  /// No description provided for @addClass.
  ///
  /// In en, this message translates to:
  /// **'Add class'**
  String get addClass;

  /// No description provided for @editClass.
  ///
  /// In en, this message translates to:
  /// **'Edit class'**
  String get editClass;

  /// No description provided for @freeTimeForYou.
  ///
  /// In en, this message translates to:
  /// **'{duration} for you'**
  String freeTimeForYou(String duration);

  /// No description provided for @freeTimeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A good time to recharge or review'**
  String get freeTimeSubtitle;

  /// No description provided for @overlapWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: Overlaps with another scheduled class'**
  String get overlapWarning;

  /// No description provided for @stayOnTrack.
  ///
  /// In en, this message translates to:
  /// **'Stay on track'**
  String get stayOnTrack;

  /// No description provided for @minAttendanceHeader.
  ///
  /// In en, this message translates to:
  /// **'Your minimum attendance: {percent}% · Edit in Settings'**
  String minAttendanceHeader(String percent);

  /// No description provided for @attended.
  ///
  /// In en, this message translates to:
  /// **'Attended'**
  String get attended;

  /// No description provided for @missed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get missed;

  /// No description provided for @safeStatus.
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get safeStatus;

  /// No description provided for @atLimitStatus.
  ///
  /// In en, this message translates to:
  /// **'At the limit'**
  String get atLimitStatus;

  /// No description provided for @needsAttentionStatus.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get needsAttentionStatus;

  /// No description provided for @impossibleStatus.
  ///
  /// In en, this message translates to:
  /// **'Cannot be reached'**
  String get impossibleStatus;

  /// No description provided for @noAttendanceRecorded.
  ///
  /// In en, this message translates to:
  /// **'No attendance recorded'**
  String get noAttendanceRecorded;

  /// No description provided for @deadlinesTitle.
  ///
  /// In en, this message translates to:
  /// **'A little ahead'**
  String get deadlinesTitle;

  /// No description provided for @addDeadline.
  ///
  /// In en, this message translates to:
  /// **'Add deadline'**
  String get addDeadline;

  /// No description provided for @editDeadline.
  ///
  /// In en, this message translates to:
  /// **'Edit deadline'**
  String get editDeadline;

  /// No description provided for @filterUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get filterUpcoming;

  /// No description provided for @filterOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get filterOverdue;

  /// No description provided for @filterCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get filterCompleted;

  /// No description provided for @swipeToCompleteHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe right on a deadline to complete it.'**
  String get swipeToCompleteHint;

  /// No description provided for @markAsDone.
  ///
  /// In en, this message translates to:
  /// **'Mark as done'**
  String get markAsDone;

  /// No description provided for @restoreDeadline.
  ///
  /// In en, this message translates to:
  /// **'Restore deadline'**
  String get restoreDeadline;

  /// No description provided for @noDeadlines.
  ///
  /// In en, this message translates to:
  /// **'No deadlines here!'**
  String get noDeadlines;

  /// No description provided for @gpaTitle.
  ///
  /// In en, this message translates to:
  /// **'Your next milestone'**
  String get gpaTitle;

  /// No description provided for @gpaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Plan with confidence.'**
  String get gpaSubtitle;

  /// No description provided for @currentGpa.
  ///
  /// In en, this message translates to:
  /// **'Current GPA'**
  String get currentGpa;

  /// No description provided for @targetGpa.
  ///
  /// In en, this message translates to:
  /// **'Target GPA'**
  String get targetGpa;

  /// No description provided for @exploreWhatIf.
  ///
  /// In en, this message translates to:
  /// **'Explore what-if grades'**
  String get exploreWhatIf;

  /// No description provided for @editTargetAndCompleted.
  ///
  /// In en, this message translates to:
  /// **'Edit target & completed grades'**
  String get editTargetAndCompleted;

  /// No description provided for @whatIfTitle.
  ///
  /// In en, this message translates to:
  /// **'What-if planner'**
  String get whatIfTitle;

  /// No description provided for @projectedGpa.
  ///
  /// In en, this message translates to:
  /// **'Projected GPA'**
  String get projectedGpa;

  /// No description provided for @resetPlan.
  ///
  /// In en, this message translates to:
  /// **'Reset plan'**
  String get resetPlan;

  /// No description provided for @focusTitle.
  ///
  /// In en, this message translates to:
  /// **'One thing at a time'**
  String get focusTitle;

  /// No description provided for @focusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A little focus goes a long way.'**
  String get focusSubtitle;

  /// No description provided for @startFocusing.
  ///
  /// In en, this message translates to:
  /// **'Start focusing'**
  String get startFocusing;

  /// No description provided for @pauseTimer.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseTimer;

  /// No description provided for @resumeTimer.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resumeTimer;

  /// No description provided for @endSession.
  ///
  /// In en, this message translates to:
  /// **'End session'**
  String get endSession;

  /// No description provided for @takeABreak.
  ///
  /// In en, this message translates to:
  /// **'Take a 5-min break'**
  String get takeABreak;

  /// No description provided for @focusComplete.
  ///
  /// In en, this message translates to:
  /// **'Focus session complete!'**
  String get focusComplete;

  /// No description provided for @seeStudyStats.
  ///
  /// In en, this message translates to:
  /// **'See your study stats'**
  String get seeStudyStats;

  /// No description provided for @studyStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'See your progress'**
  String get studyStatsTitle;

  /// No description provided for @dailyFocusMinutes.
  ///
  /// In en, this message translates to:
  /// **'Daily focus · minutes'**
  String get dailyFocusMinutes;

  /// No description provided for @byModule.
  ///
  /// In en, this message translates to:
  /// **'By module'**
  String get byModule;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'{count}-day streak'**
  String dayStreak(int count);

  /// No description provided for @boardNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your board notes'**
  String get boardNotesTitle;

  /// No description provided for @boardNotesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'All your lecture snapshots, together.'**
  String get boardNotesSubtitle;

  /// No description provided for @captureBoard.
  ///
  /// In en, this message translates to:
  /// **'Capture a board'**
  String get captureBoard;

  /// No description provided for @moduleFolder.
  ///
  /// In en, this message translates to:
  /// **'Module folder'**
  String get moduleFolder;

  /// No description provided for @noPhotosYet.
  ///
  /// In en, this message translates to:
  /// **'No photos yet · Capture your first note'**
  String get noPhotosYet;

  /// No description provided for @deletePhotoConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this board photo?'**
  String get deletePhotoConfirm;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Make it work for you'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Everything stays on this phone.'**
  String get settingsSubtitle;

  /// No description provided for @settingLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingLanguage;

  /// No description provided for @settingAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingAppearance;

  /// No description provided for @settingAcademicRules.
  ///
  /// In en, this message translates to:
  /// **'Academic rules'**
  String get settingAcademicRules;

  /// No description provided for @settingReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get settingReminders;

  /// No description provided for @settingBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get settingBackup;

  /// No description provided for @settingModules.
  ///
  /// In en, this message translates to:
  /// **'Modules'**
  String get settingModules;

  /// No description provided for @exportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get exportBackup;

  /// No description provided for @importBackup.
  ///
  /// In en, this message translates to:
  /// **'Import backup'**
  String get importBackup;

  /// No description provided for @backupExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup exported successfully'**
  String get backupExportSuccess;

  /// No description provided for @backupImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup restored successfully'**
  String get backupImportSuccess;

  /// No description provided for @backHome.
  ///
  /// In en, this message translates to:
  /// **'Back home'**
  String get backHome;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'si'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'si':
      return AppLocalizationsSi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
