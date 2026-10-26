class ClassSession {
  final String id;
  final String moduleId;
  final int dayOfWeek; // 1 = Monday, 7 = Sunday
  final String startTime; // 'HH:mm' e.g. '10:30'
  final String endTime; // 'HH:mm' e.g. '12:30'
  final String room; // e.g. 'Hall 301' or 'Lab 3'
  final String type; // 'Lecture', 'Lab', 'Tutorial', 'Workshop'
  final String? notes;

  const ClassSession({
    required this.id,
    required this.moduleId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.room,
    this.type = 'Lecture',
    this.notes,
  });

  int get startMinutes => _timeToMinutes(startTime);
  int get endMinutes => _timeToMinutes(endTime);
  int get durationMinutes => endMinutes - startMinutes;

  static int _timeToMinutes(String time) {
    final parts = time.split(':');
    final hours = int.tryParse(parts[0]) ?? 0;
    final mins = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return hours * 60 + mins;
  }

  ClassSession copyWith({
    String? id,
    String? moduleId,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? room,
    String? type,
    String? notes,
  }) {
    return ClassSession(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
      type: type ?? this.type,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'module_id': moduleId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'room': room,
      'type': type,
      'notes': notes,
    };
  }

  factory ClassSession.fromMap(Map<String, dynamic> map) {
    return ClassSession(
      id: map['id'] as String,
      moduleId: map['module_id'] as String,
      dayOfWeek: (map['day_of_week'] as num).toInt(),
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
      room: map['room'] as String,
      type: map['type'] as String? ?? 'Lecture',
      notes: map['notes'] as String?,
    );
  }
}
