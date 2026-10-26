import 'dart:convert';

class AcademicSettings {
  final Map<String, double> gradeScale;
  final double minAttendancePercent;
  final double targetGpa;

  const AcademicSettings({
    required this.gradeScale,
    this.minAttendancePercent = 80.0,
    this.targetGpa = 3.30,
  });

  static const Map<String, double> defaultSliitGradeScale = {
    'A+': 4.0,
    'A': 4.0,
    'A-': 3.7,
    'B+': 3.3,
    'B': 3.0,
    'B-': 2.7,
    'C+': 2.3,
    'C': 2.0,
    'C-': 1.7,
    'D+': 1.3,
    'D': 1.0,
    'E': 0.0,
  };

  factory AcademicSettings.initial() {
    return const AcademicSettings(
      gradeScale: defaultSliitGradeScale,
      minAttendancePercent: 80.0,
      targetGpa: 3.30,
    );
  }

  AcademicSettings copyWith({
    Map<String, double>? gradeScale,
    double? minAttendancePercent,
    double? targetGpa,
  }) {
    return AcademicSettings(
      gradeScale: gradeScale ?? this.gradeScale,
      minAttendancePercent: minAttendancePercent ?? this.minAttendancePercent,
      targetGpa: targetGpa ?? this.targetGpa,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'grade_scale': jsonEncode(gradeScale),
      'min_attendance_percent': minAttendancePercent,
      'target_gpa': targetGpa,
    };
  }

  factory AcademicSettings.fromMap(Map<String, dynamic> map) {
    Map<String, double> scale = Map<String, double>.from(defaultSliitGradeScale);
    if (map['grade_scale'] != null) {
      try {
        final decoded = jsonDecode(map['grade_scale'] as String) as Map<String, dynamic>;
        scale = decoded.map((k, v) => MapEntry(k, (v as num).toDouble()));
      } catch (_) {}
    }
    return AcademicSettings(
      gradeScale: scale,
      minAttendancePercent: (map['min_attendance_percent'] as num?)?.toDouble() ?? 80.0,
      targetGpa: (map['target_gpa'] as num?)?.toDouble() ?? 3.30,
    );
  }
}
