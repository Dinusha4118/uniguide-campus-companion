class AttendanceRecord {
  final String id;
  final String moduleId;
  final String lectureDate; // YYYY-MM-DD
  final bool isAttended;
  final DateTime timestamp;

  const AttendanceRecord({
    required this.id,
    required this.moduleId,
    required this.lectureDate,
    required this.isAttended,
    required this.timestamp,
  });

  AttendanceRecord copyWith({
    String? id,
    String? moduleId,
    String? lectureDate,
    bool? isAttended,
    DateTime? timestamp,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      lectureDate: lectureDate ?? this.lectureDate,
      isAttended: isAttended ?? this.isAttended,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'module_id': moduleId,
      'lecture_date': lectureDate,
      'is_attended': isAttended ? 1 : 0,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'] as String,
      moduleId: map['module_id'] as String,
      lectureDate: map['lecture_date'] as String,
      isAttended: (map['is_attended'] as int? ?? 0) == 1,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}
