class Deadline {
  final String id;
  final String moduleId;
  final String title;
  final DateTime dueDateTime;
  final String type; // 'assignment', 'quiz', 'viva', 'exam', 'other'
  final String? notes;
  final bool isCompleted;
  final DateTime? completedAt;

  const Deadline({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.dueDateTime,
    this.type = 'assignment',
    this.notes,
    this.isCompleted = false,
    this.completedAt,
  });

  Deadline copyWith({
    String? id,
    String? moduleId,
    String? title,
    DateTime? dueDateTime,
    String? type,
    String? notes,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return Deadline(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      title: title ?? this.title,
      dueDateTime: dueDateTime ?? this.dueDateTime,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'module_id': moduleId,
      'title': title,
      'due_datetime': dueDateTime.toIso8601String(),
      'type': type,
      'notes': notes,
      'is_completed': isCompleted ? 1 : 0,
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  factory Deadline.fromMap(Map<String, dynamic> map) {
    return Deadline(
      id: map['id'] as String,
      moduleId: map['module_id'] as String,
      title: map['title'] as String,
      dueDateTime: DateTime.parse(map['due_datetime'] as String),
      type: map['type'] as String? ?? 'assignment',
      notes: map['notes'] as String?,
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
      completedAt: map['completed_at'] != null ? DateTime.parse(map['completed_at'] as String) : null,
    );
  }
}
