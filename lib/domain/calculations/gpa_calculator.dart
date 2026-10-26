import '../models/module.dart';

class GpaCalculationResult {
  final double currentGpa;
  final int completedCredits;
  final double totalGradePoints;

  const GpaCalculationResult({
    required this.currentGpa,
    required this.completedCredits,
    required this.totalGradePoints,
  });
}

enum TargetFeasibilityStatus {
  achievable,
  alreadyAchieved,
  impossibleTooHigh,
  noRemainingCredits,
  invalidTarget,
}

class RequiredTargetResult {
  final double? requiredAverage;
  final TargetFeasibilityStatus status;
  final String message;

  const RequiredTargetResult({
    required this.requiredAverage,
    required this.status,
    required this.message,
  });
}

class GpaCalculator {
  static GpaCalculationResult calculateCurrentGpa(
    List<Module> modules,
    Map<String, double> gradeScale,
  ) {
    int totalCredits = 0;
    double totalPoints = 0.0;

    for (final module in modules) {
      if (module.isCompleted && module.completedGrade != null) {
        final point = gradeScale[module.completedGrade!];
        if (point != null && module.credits > 0) {
          totalCredits += module.credits;
          totalPoints += point * module.credits;
        }
      }
    }

    final gpa = totalCredits > 0 ? (totalPoints / totalCredits) : 0.0;
    return GpaCalculationResult(
      currentGpa: gpa,
      completedCredits: totalCredits,
      totalGradePoints: totalPoints,
    );
  }

  static RequiredTargetResult calculateRequiredRemainingAverage({
    required int completedCredits,
    required double completedPoints,
    required int remainingCredits,
    required double targetGpa,
    required Map<String, double> gradeScale,
  }) {
    final maxScale = gradeScale.values.isNotEmpty
        ? gradeScale.values.reduce((a, b) => a > b ? a : b)
        : 4.0;
    final minScale = gradeScale.values.isNotEmpty
        ? gradeScale.values.reduce((a, b) => a < b ? a : b)
        : 0.0;

    if (targetGpa < minScale || targetGpa > maxScale) {
      return const RequiredTargetResult(
        requiredAverage: null,
        status: TargetFeasibilityStatus.invalidTarget,
        message: 'Target GPA is outside the valid grading scale.',
      );
    }

    if (remainingCredits <= 0) {
      final currentGpa = completedCredits > 0 ? completedPoints / completedCredits : 0.0;
      if (currentGpa >= targetGpa) {
        return const RequiredTargetResult(
          requiredAverage: null,
          status: TargetFeasibilityStatus.alreadyAchieved,
          message: 'Target reached with current completed modules.',
        );
      }
      return const RequiredTargetResult(
        requiredAverage: null,
        status: TargetFeasibilityStatus.noRemainingCredits,
        message: 'No remaining credits to improve GPA.',
      );
    }

    final totalCredits = completedCredits + remainingCredits;
    final requiredTotalPoints = targetGpa * totalCredits;
    final neededPointsFromRemaining = requiredTotalPoints - completedPoints;
    final requiredAverage = neededPointsFromRemaining / remainingCredits;

    if (requiredAverage > maxScale) {
      return RequiredTargetResult(
        requiredAverage: requiredAverage,
        status: TargetFeasibilityStatus.impossibleTooHigh,
        message: 'Requires an average of ${requiredAverage.toStringAsFixed(2)}, which exceeds the maximum possible ($maxScale).',
      );
    }

    if (requiredAverage <= minScale) {
      return RequiredTargetResult(
        requiredAverage: requiredAverage,
        status: TargetFeasibilityStatus.alreadyAchieved,
        message: 'Target already mathematically achieved regardless of future grades.',
      );
    }

    return RequiredTargetResult(
      requiredAverage: requiredAverage,
      status: TargetFeasibilityStatus.achievable,
      message: 'Aim for a ${requiredAverage.toStringAsFixed(2)} average across remaining credits.',
    );
  }

  static double calculateProjectedGpa({
    required List<Module> completedModules,
    required Map<String, String> plannedGrades, // moduleId -> grade e.g. 'A'
    required List<Module> remainingModules,
    required Map<String, double> gradeScale,
  }) {
    int totalCredits = 0;
    double totalPoints = 0.0;

    for (final module in completedModules) {
      if (module.isCompleted && module.completedGrade != null) {
        final point = gradeScale[module.completedGrade!];
        if (point != null && module.credits > 0) {
          totalCredits += module.credits;
          totalPoints += point * module.credits;
        }
      }
    }

    for (final module in remainingModules) {
      final plannedGrade = plannedGrades[module.id];
      if (plannedGrade != null) {
        final point = gradeScale[plannedGrade];
        if (point != null && module.credits > 0) {
          totalCredits += module.credits;
          totalPoints += point * module.credits;
        }
      }
    }

    return totalCredits > 0 ? (totalPoints / totalCredits) : 0.0;
  }
}
