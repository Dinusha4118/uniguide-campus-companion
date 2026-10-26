import '../models/deadline.dart';

enum DeadlineUrgency {
  overdue,
  urgentUnder2Days,
  warningUnder7Days,
  calmLater,
}

class DeadlineCalculator {
  static DeadlineUrgency getUrgency(DateTime dueDateTime, DateTime now) {
    final diff = dueDateTime.difference(now);
    if (diff.isNegative) {
      return DeadlineUrgency.overdue;
    }
    if (diff.inHours < 48) {
      return DeadlineUrgency.urgentUnder2Days;
    }
    if (diff.inDays < 7) {
      return DeadlineUrgency.warningUnder7Days;
    }
    return DeadlineUrgency.calmLater;
  }

  static String formatCountdown(DateTime dueDateTime, DateTime now) {
    final diff = dueDateTime.difference(now);
    if (diff.isNegative) {
      final absMins = diff.inMinutes.abs();
      if (absMins < 60) return 'Overdue by $absMins min';
      final absHours = diff.inHours.abs();
      if (absHours < 24) return 'Overdue by $absHours ${absHours == 1 ? 'hour' : 'hours'}';
      final absDays = diff.inDays.abs();
      return 'Overdue by $absDays ${absDays == 1 ? 'day' : 'days'}';
    }

    if (diff.inHours < 1) {
      return 'Due in ${diff.inMinutes} min';
    }
    if (diff.inHours < 24) {
      return 'Due in ${diff.inHours} ${diff.inHours == 1 ? 'hour' : 'hours'}';
    }
    if (diff.inDays == 1) {
      return '1 day left';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} days left';
    }
    final weeks = diff.inDays ~/ 7;
    return 'in $weeks ${weeks == 1 ? 'week' : 'weeks'}';
  }

  static List<Deadline> sortDeadlines(List<Deadline> deadlines) {
    final sorted = List<Deadline>.from(deadlines);
    sorted.sort((a, b) {
      // Uncompleted deadlines come first
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return a.dueDateTime.compareTo(b.dueDateTime);
    });
    return sorted;
  }

  static List<Deadline> filterUpcoming(List<Deadline> deadlines, DateTime now) {
    return deadlines.where((d) => !d.isCompleted && d.dueDateTime.isAfter(now)).toList()
      ..sort((a, b) => a.dueDateTime.compareTo(b.dueDateTime));
  }

  static List<Deadline> filterOverdue(List<Deadline> deadlines, DateTime now) {
    return deadlines.where((d) => !d.isCompleted && d.dueDateTime.isBefore(now)).toList()
      ..sort((a, b) => a.dueDateTime.compareTo(b.dueDateTime));
  }

  static List<Deadline> filterCompleted(List<Deadline> deadlines) {
    return deadlines.where((d) => d.isCompleted).toList()
      ..sort((a, b) => (b.completedAt ?? b.dueDateTime).compareTo(a.completedAt ?? a.dueDateTime));
  }
}
