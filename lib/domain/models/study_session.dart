class StudySession {
  final String id;
  final String moduleId;
  final int durationSeconds;
  final DateTime timestamp;
  final String sessionType; // 'focus', 'break'

  const StudySession({
    required this.id,
    required this.moduleId,
    required this.durationSeconds,
    required this.timestamp,
    this.sessionType = 'focus',
  });

  StudySession copyWith({
    String? id,
    String? moduleId,
    int? durationSeconds,
    DateTime? timestamp,
    String? sessionType,
  }) {
    return StudySession(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      timestamp: timestamp ?? this.timestamp,
      sessionType: sessionType ?? this.sessionType,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'module_id': moduleId,
      'duration_seconds': durationSeconds,
      'timestamp': timestamp.toIso8601String(),
      'session_type': sessionType,
    };
  }

  factory StudySession.fromMap(Map<String, dynamic> map) {
    return StudySession(
      id: map['id'] as String,
      moduleId: map['module_id'] as String,
      durationSeconds: (map['duration_seconds'] as num).toInt(),
      timestamp: DateTime.parse(map['timestamp'] as String),
      sessionType: map['session_type'] as String? ?? 'focus',
    );
  }
}
