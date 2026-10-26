import 'dart:math' as math;

enum AttendanceStatus {
  noRecords,
  safe,
  atLimit,
  needsAttention,
  impossible,
}

class AttendanceSafeSkipResult {
  final double? currentPercentage;
  final int attended;
  final int missed;
  final int recordedLectures;
  final int plannedLectures;
  final int requiredAttended;
  final int maximumAllowedMisses;
  final int remainingLectures;
  final int safeAdditionalMisses;
  final bool isFeasible;
  final AttendanceStatus status;
  final String statusText;
  final String descriptionText;

  const AttendanceSafeSkipResult({
    required this.currentPercentage,
    required this.attended,
    required this.missed,
    required this.recordedLectures,
    required this.plannedLectures,
    required this.requiredAttended,
    required this.maximumAllowedMisses,
    required this.remainingLectures,
    required this.safeAdditionalMisses,
    required this.isFeasible,
    required this.status,
    required this.statusText,
    required this.descriptionText,
  });
}

class AttendanceCalculator {
  static double? calculateAttendancePercentage(int attended, int missed) {
    final total = attended + missed;
    if (total <= 0) return null;
    return (attended / total) * 100.0;
  }

  static AttendanceSafeSkipResult calculateSafeSkips({
    required int attended,
    required int missed,
    required int plannedLectures,
    double minAttendanceFraction = 0.80, // e.g. 80% = 0.80
  }) {
    final recordedLectures = attended + missed;
    final currentPercentage = calculateAttendancePercentage(attended, missed);

    if (plannedLectures <= 0) {
      return AttendanceSafeSkipResult(
        currentPercentage: currentPercentage,
        attended: attended,
        missed: missed,
        recordedLectures: recordedLectures,
        plannedLectures: 0,
        requiredAttended: 0,
        maximumAllowedMisses: 0,
        remainingLectures: 0,
        safeAdditionalMisses: 0,
        isFeasible: true,
        status: currentPercentage == null
            ? AttendanceStatus.noRecords
            : (currentPercentage >= (minAttendanceFraction * 100)
                ? AttendanceStatus.safe
                : AttendanceStatus.needsAttention),
        statusText: currentPercentage == null ? 'No records' : '${currentPercentage.toStringAsFixed(0)}%',
        descriptionText: 'Set planned lectures in module settings to calculate safe misses.',
      );
    }

    final requiredAttended = (plannedLectures * minAttendanceFraction).ceil();
    final maximumAllowedMisses = plannedLectures - requiredAttended;
    final remainingLectures = math.max(0, plannedLectures - recordedLectures);
    final isFeasible = (attended + remainingLectures) >= requiredAttended;

    int safeAdditionalMisses = 0;
    if (isFeasible) {
      safeAdditionalMisses = math.min(
        remainingLectures,
        math.max(0, maximumAllowedMisses - missed),
      );
    }

    AttendanceStatus status;
    String statusText;
    String descriptionText;

    final targetPercent = (minAttendanceFraction * 100).toStringAsFixed(0);

    if (recordedLectures == 0) {
      status = AttendanceStatus.noRecords;
      statusText = 'No attendance recorded';
      descriptionText = 'You can miss up to $maximumAllowedMisses lectures to stay above $targetPercent%.';
    } else if (!isFeasible) {
      status = AttendanceStatus.impossible;
      statusText = 'Target cannot be reached';
      descriptionText = 'Even attending all $remainingLectures remaining lectures will not reach $targetPercent%.';
    } else if (safeAdditionalMisses == 0) {
      status = AttendanceStatus.atLimit;
      statusText = 'At the limit';
      descriptionText = 'Attend all remaining $remainingLectures classes to stay above $targetPercent%.';
    } else if ((currentPercentage ?? 0.0) < (minAttendanceFraction * 100)) {
      status = AttendanceStatus.needsAttention;
      statusText = 'Needs attention';
      final neededToCatchUp = requiredAttended - attended;
      descriptionText = 'Attend next $neededToCatchUp classes to reach $targetPercent%.';
    } else {
      status = AttendanceStatus.safe;
      statusText = 'Safe';
      descriptionText = safeAdditionalMisses == 1
          ? 'You can miss 1 more lecture.'
          : 'You can miss $safeAdditionalMisses more lectures.';
    }

    return AttendanceSafeSkipResult(
      currentPercentage: currentPercentage,
      attended: attended,
      missed: missed,
      recordedLectures: recordedLectures,
      plannedLectures: plannedLectures,
      requiredAttended: requiredAttended,
      maximumAllowedMisses: maximumAllowedMisses,
      remainingLectures: remainingLectures,
      safeAdditionalMisses: safeAdditionalMisses,
      isFeasible: isFeasible,
      status: status,
      statusText: statusText,
      descriptionText: descriptionText,
    );
  }
}
