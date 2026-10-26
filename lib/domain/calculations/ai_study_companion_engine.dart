import 'dart:math';
import '../models/module.dart';
import '../models/deadline.dart';
import '../models/attendance_record.dart';
import '../models/study_session.dart';
import '../models/academic_settings.dart';

class DailyBriefingResult {
  final String greetingTitle;
  final String motivationalQuote;
  final int academicHealthScore; // 0 - 100
  final String statusSummary;
  final List<String> topPriorityActions;
  final String studySuggestion;
  final String attendanceAlert;

  const DailyBriefingResult({
    required this.greetingTitle,
    required this.motivationalQuote,
    required this.academicHealthScore,
    required this.statusSummary,
    required this.topPriorityActions,
    required this.studySuggestion,
    required this.attendanceAlert,
  });
}

class AiStudyPlanDay {
  final String dayName;
  final String moduleCode;
  final String moduleName;
  final int allocatedMinutes;
  final String priorityLevel; // 'HIGH', 'MEDIUM', 'LOW'
  final String focusTopic;

  const AiStudyPlanDay({
    required this.dayName,
    required this.moduleCode,
    required this.moduleName,
    required this.allocatedMinutes,
    required this.priorityLevel,
    required this.focusTopic,
  });
}

class AiGpaRoadmapMilestone {
  final String targetGrade;
  final double requiredGpaForModule;
  final String moduleCode;
  final String moduleName;
  final int credits;
  final String studyIntensity; // 'HIGH', 'MODERATE', 'MAINTAIN'
  final String tacticalAdvice;

  const AiGpaRoadmapMilestone({
    required this.targetGrade,
    required this.requiredGpaForModule,
    required this.moduleCode,
    required this.moduleName,
    required this.credits,
    required this.studyIntensity,
    required this.tacticalAdvice,
  });
}

class AiBoardFlashcard {
  final String question;
  final String answer;
  final String category;

  const AiBoardFlashcard({
    required this.question,
    required this.answer,
    required this.category,
  });
}

class AiStudyCompanionEngine {
  /// 1. AI Daily Academic Briefing
  static DailyBriefingResult generateDailyBriefing({
    required String studentName,
    required List<Module> modules,
    required List<Deadline> deadlines,
    required List<AttendanceRecord> attendanceRecords,
    required List<StudySession> studySessions,
    required AcademicSettings academicSettings,
    required DateTime now,
    bool isSinhala = false,
  }) {
    final pendingDeadlines = deadlines.where((d) => !d.isCompleted).toList();
    final urgentDeadlines = pendingDeadlines.where((d) {
      final diff = d.dueDateTime.difference(now).inHours;
      return diff >= 0 && diff <= 48;
    }).toList();

    // Calculate score
    int baseScore = 100;
    if (urgentDeadlines.length >= 2) baseScore -= 18;
    if (pendingDeadlines.length > 5) baseScore -= 10;

    // Check attendance factor
    int attendanceDeficits = 0;
    for (final mod in modules) {
      final records = attendanceRecords.where((r) => r.moduleId == mod.id).toList();
      final attended = records.where((r) => r.isAttended).length;
      final total = records.length;
      if (total >= 4 && (attended / total) < (academicSettings.minAttendancePercent / 100.0)) {
        attendanceDeficits++;
      }
    }
    baseScore -= (attendanceDeficits * 12);
    final finalScore = baseScore.clamp(35, 100);

    // Actions
    final List<String> actions = [];
    if (urgentDeadlines.isNotEmpty) {
      for (final ud in urgentDeadlines.take(2)) {
        actions.add(isSinhala
            ? 'පැය 48 ඇතුළත සම්පූර්ණ කරන්න: ${ud.title}'
            : 'Urgent deadline in 48h: ${ud.title}');
      }
    } else if (pendingDeadlines.isNotEmpty) {
      actions.add(isSinhala
          ? 'ඉදිරියට ඇති පැවරුම් සූදානම් වන්න: ${pendingDeadlines.first.title}'
          : 'Prepare upcoming task: ${pendingDeadlines.first.title}');
    } else {
      actions.add(isSinhala ? 'සියලු පැවරුම් සම්පූර්ණයි! විවේකයක් ගන්න.' : 'No pending deadlines! Keep revision steady.');
    }

    if (attendanceDeficits > 0) {
      actions.add(isSinhala
          ? 'විෂයයන් $attendanceDeficits ක අවම පැමිණීම අවදානමක. මීළඟ දේශන අතපසු නොකරන්න!'
          : 'Attendance alert in $attendanceDeficits module(s). Do not skip upcoming classes!');
    }

    final quotes = isSinhala
        ? [
            'විශ්වාසයෙන් හා අඛණ්ඩ උත්සාහයෙන් ඕනෑම ඉලක්කයක් ජයගත හැක.',
            'සුළු උත්සාහයන් දිනපතා එක්රැස්වීමෙන් විශිෂ්ට ප්‍රතිඵල බිහිවේ.',
            'අද දවසේ කැපවීම ඔබගේ අනාගත සාර්ථකත්වයේ පදනමයි.',
          ]
        : [
            'Consistency is the secret sauce of academic mastery.',
            'Small daily focus blocks compound into remarkable grades.',
            'Focus on the process today, and your GPA will take care of itself.',
          ];

    final quote = quotes[now.day % quotes.length];

    String statusText;
    if (finalScore >= 85) {
      statusText = isSinhala ? 'ඔබ විශිෂ්ට මට්ටමක සිටී!' : 'Prime Academic Standing';
    } else if (finalScore >= 70) {
      statusText = isSinhala ? 'ස්ථාවර මට්ටමක් – අඛණ්ඩව කරගෙන යන්න' : 'Good Momentum – Keep Consistent';
    } else {
      statusText = isSinhala ? 'අවධානය අවශ්‍යයි – කාලය සැලසුම් කරගන්න' : 'Action Required – Prioritize Critical Tasks';
    }

    return DailyBriefingResult(
      greetingTitle: isSinhala ? 'ආයුබෝවන්, $studentName!' : 'Hello, $studentName!',
      motivationalQuote: quote,
      academicHealthScore: finalScore,
      statusSummary: statusText,
      topPriorityActions: actions,
      studySuggestion: isSinhala
          ? 'අද දින විනාඩි 25 ක Pomodoro සැසි 2 ක් අවසන් කිරීම නිර්දේශ කෙරේ.'
          : 'Recommended: Target 2 focused 25-min Pomodoro sessions today.',
      attendanceAlert: attendanceDeficits > 0
          ? (isSinhala ? 'අවම පැමිණීම රැකගැනීමට වහාම අවධානය දෙන්න.' : 'Safe skip limit nearly reached in weak modules.')
          : (isSinhala ? 'පැමිණීම ආරක්ෂිත මට්ටමක පවතී.' : 'Attendance safely above target across registered modules.'),
    );
  }

  /// 2. AI Smart Study Schedule Generator
  static List<AiStudyPlanDay> generateWeeklyStudyPlan({
    required List<Module> modules,
    required List<Deadline> deadlines,
    required int dailyBudgetMinutes,
    bool isSinhala = false,
  }) {
    if (modules.isEmpty) return [];

    final days = isSinhala
        ? ['සඳුදා', 'අඟහරුවාදා', 'බදාදා', 'බ්‍රහස්පතින්දා', 'සිකුරාදා', 'සෙනසුරාදා', 'ඉරිදා']
        : ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    // Sort modules by urgency / credits
    final sortedModules = List<Module>.from(modules);
    sortedModules.sort((a, b) => b.credits.compareTo(a.credits));

    final List<AiStudyPlanDay> plan = [];

    for (int i = 0; i < 7; i++) {
      final mod = sortedModules[i % sortedModules.length];
      final isWeekend = (i == 5 || i == 6);
      final allocated = isWeekend ? (dailyBudgetMinutes * 0.75).round() : dailyBudgetMinutes;

      final moduleDeadlines = deadlines.where((d) => d.moduleId == mod.id && !d.isCompleted).toList();
      String priority = 'MEDIUM';
      String topic = isSinhala ? 'මූලික සංකල්ප සමාලෝචනය' : 'Core lecture concept revision';

      if (moduleDeadlines.isNotEmpty) {
        priority = 'HIGH';
        topic = isSinhala
            ? 'පැවරුම/විභාගය සඳහා සූදානම් වීම: ${moduleDeadlines.first.title}'
            : 'Prepare submission for: ${moduleDeadlines.first.title}';
      } else if (mod.credits >= 4) {
        priority = 'HIGH';
        topic = isSinhala ? 'ගැඹුරු අභ්‍යාස හා සටහන් කියවීම' : 'Advanced problem solving & review';
      }

      plan.add(AiStudyPlanDay(
        dayName: days[i],
        moduleCode: mod.code,
        moduleName: mod.name,
        allocatedMinutes: max(25, allocated),
        priorityLevel: priority,
        focusTopic: topic,
      ));
    }

    return plan;
  }

  /// 3. AI Smart GPA Target Roadmap
  static List<AiGpaRoadmapMilestone> generateGpaTargetRoadmap({
    required List<Module> modules,
    required double targetGpa,
    required Map<String, double> gradeScale,
    bool isSinhala = false,
  }) {
    final uncompleted = modules.where((m) => !m.isCompleted).toList();
    if (uncompleted.isEmpty) return [];

    final List<AiGpaRoadmapMilestone> roadmap = [];

    for (final mod in uncompleted) {
      String targetGrade = 'A';
      double reqPoint = 4.0;
      String intensity = 'HIGH';
      String advice = isSinhala ? 'විශිෂ්ට සාමාර්ථයක් සඳහා දිනපතා සටහන් බලන්න' : 'Aim for top bracket; maintain all tutorial submissions';

      if (targetGpa <= 3.0) {
        targetGrade = 'B';
        reqPoint = 3.0;
        intensity = 'MODERATE';
        advice = isSinhala ? 'ස්ථාවර ලකුණු මට්ටමක් පවත්වා ගන්න' : 'Consistent pass rate with timely assignment submissions';
      } else if (targetGpa <= 3.4) {
        targetGrade = 'B+';
        reqPoint = 3.3;
        intensity = 'MODERATE';
        advice = isSinhala ? 'සාමාන්‍යයෙන් ඉහළ ලකුණු ලබාගැනීම ඉලක්ක කරන්න' : 'Target above-average mid-term quiz marks';
      } else if (targetGpa <= 3.7) {
        targetGrade = 'A-';
        reqPoint = 3.7;
        intensity = 'HIGH';
        advice = isSinhala ? 'විභාග පෙරහුරු ප්‍රශ්න පත්‍ර විසඳන්න' : 'Past papers practice and consistent lab report marks';
      }

      roadmap.add(AiGpaRoadmapMilestone(
        targetGrade: targetGrade,
        requiredGpaForModule: reqPoint,
        moduleCode: mod.code,
        moduleName: mod.name,
        credits: mod.credits,
        studyIntensity: intensity,
        tacticalAdvice: advice,
      ));
    }

    return roadmap;
  }

  /// 4. AI Board Snap Flashcards / Key Points Generator
  static List<AiBoardFlashcard> generateFlashcardsFromBoardNote({
    required String moduleCode,
    required String? note,
    bool isSinhala = false,
  }) {
    final text = note?.trim() ?? '';
    final List<AiBoardFlashcard> cards = [];

    if (text.isNotEmpty) {
      cards.add(AiBoardFlashcard(
        question: isSinhala ? 'මෙම දේශනයේ ප්‍රධාන මාතෘකාව කුමක්ද?' : 'What is the central focus of this board snap?',
        answer: text,
        category: 'Concept Summary',
      ));
      cards.add(AiBoardFlashcard(
        question: isSinhala ? 'මෙහි ඇති ප්‍රධාන කරුණු මතක තබා ගන්නේ කෙසේද?' : 'How should this material be applied in exams?',
        answer: isSinhala
            ? 'මෙම සංකල්පය සම්බන්ධ කෙටි සටහන් සහ උදාහරණ කටුසටහන් පුහුණු වන්න.'
            : 'Synthesize the notes with textbook diagrams and solve 2 related practice questions.',
        category: 'Study Strategy',
      ));
    } else {
      cards.add(AiBoardFlashcard(
        question: isSinhala ? '$moduleCode දේශන සටහන' : '$moduleCode Board Lecture Snapshot',
        answer: isSinhala
            ? 'සටහන් ලියවිලි පරීක්ෂා කර සාරාංශයක් සාදාගන්න.'
            : 'Review the high-resolution board photo to annotate key formulas and proof steps.',
        category: 'Quick Review',
      ));
    }

    cards.add(AiBoardFlashcard(
      question: isSinhala ? 'සංශෝධනය සඳහා වඩාත් සුදුසු ක්‍රමය' : 'Spaced Repetition Schedule',
      answer: isSinhala
          ? 'දින 1, දින 3 සහ දින 7 යන කාල පරතරයන්හි නැවත බලන්න.'
          : 'Review after 24h, 3 days, and 1 week to lock into long-term memory.',
      category: 'Memory Anchor',
    ));

    return cards;
  }

  /// 5. AI Conversational Tutor Response Generator
  static String askAcademicAssistant({
    required String query,
    required List<Module> modules,
    required List<Deadline> deadlines,
    required double currentGpa,
    required double targetGpa,
    bool isSinhala = false,
  }) {
    final q = query.toLowerCase();

    if (q.contains('gpa') || q.contains('grade') || q.contains('ලකුණු') || q.contains('ඉලක්ක')) {
      if (isSinhala) {
        return 'ඔබගේ වත්මන් GPA අගය ${currentGpa.toStringAsFixed(2)} ක් වන අතර ඉලක්කය ${targetGpa.toStringAsFixed(2)} කි. ඉදිරි විෂයයන් වලදී වැඩි බැර (credits) සහිත විෂයයන් සඳහා A හෝ B+ ශ්‍රේණි ලබාගැනීමෙන් ඔබගේ ඉලක්කය පහසුවෙන් සපුරා ගත හැක.';
      }
      return 'Your current GPA is ${currentGpa.toStringAsFixed(2)} and your target is ${targetGpa.toStringAsFixed(2)}. Focus heavily on high-credit (3-4 cr) modules. Earning A/A- in those creates the greatest upward lift on your cumulative score.';
    }

    if (q.contains('deadline') || q.contains('assignment') || q.contains('පැවරුම්') || q.contains('විභාග')) {
      final pending = deadlines.where((d) => !d.isCompleted).toList();
      if (pending.isEmpty) {
        return isSinhala
            ? 'නියමිත කාලසීමා සහිත පැවරුම් සියල්ල ඔබ සාර්ථකව අවසන් කර ඇත!'
            : 'You currently have zero pending deadlines! You are completely on schedule.';
      }
      final first = pending.first;
      return isSinhala
          ? 'ඔබට ඉදිරියට නියමිත කාර්යයන් ${pending.length} ක් ඇත. මීළඟට සම්පූර්ණ කළ යුත්තේ: "${first.title}".'
          : 'You have ${pending.length} active deadline(s). Next priority submission is "${first.title}". Break it down into 3 milestones today.';
    }

    if (q.contains('attendance') || q.contains('skip') || q.contains('පැමිණීම') || q.contains('දේශන')) {
      return isSinhala
          ? 'විභාග සුදුසුකම් සපුරා ගැනීමට අවම වශයෙන් 80% පැමිණීමක් අවශ්‍ය වේ. විෂයයක පැමිණීම 80% සීමාවට ආසන්න නම් කිසිදු දේශනයක් මඟනොහරින්න.'
          : 'Campus policy typically requires at least 80% attendance to qualify for final exams. If your safe misses for any module shows 0, attend every remaining lecture without exception!';
    }

    if (q.contains('stress') || q.contains('tired') || q.contains('මහන්සි') || q.contains('බය')) {
      return isSinhala
          ? 'විශ්වවිද්‍යාල ජීවිතයේ පීඩනය සාමාන්‍යයි. විනාඩි 10 ක කෙටි ඇවිදීමක් හෝ ගැඹුරු හුස්ම ගැනීමේ විවේකයක් ගන්න. පසුව කුඩා කොටස් වශයෙන් නැවත ආරම්භ කරන්න!'
          : 'University workload can be demanding. Take a 10-minute screen-free break, drink water, and conquer just one 25-minute Pomodoro session. You have got this!';
    }

    // Default intelligent guidance
    if (isSinhala) {
      return 'මම ඔබගේ AI විශ්වවිද්‍යාල අධ්‍යයන සහායකයා වෙමි. ඔබට GPA සැලසුම් කිරීම, පැමිණීම පාලනය, ඉදිරි පැවරුම් හෝ පාඩම් කාලසටහන් ගැන ඕනෑම දෙයක් මාගෙන් විමසිය හැක.';
    }
    return 'I am your UniGuide Academic AI Mentor. You can ask me how to maximize your GPA, plan study sprints around deadlines, or optimize attendance safe skips!';
  }
}
