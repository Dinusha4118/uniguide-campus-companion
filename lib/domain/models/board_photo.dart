class BoardPhoto {
  final String id;
  final String moduleId;
  final String filePath;
  final String? thumbnailPath;
  final DateTime capturedDate;
  final String? note;

  const BoardPhoto({
    required this.id,
    required this.moduleId,
    required this.filePath,
    this.thumbnailPath,
    required this.capturedDate,
    this.note,
  });

  String get lectureDate =>
      '${capturedDate.year.toString().padLeft(4, '0')}-${capturedDate.month.toString().padLeft(2, '0')}-${capturedDate.day.toString().padLeft(2, '0')}';

  BoardPhoto copyWith({
    String? id,
    String? moduleId,
    String? filePath,
    String? thumbnailPath,
    DateTime? capturedDate,
    String? note,
  }) {
    return BoardPhoto(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      filePath: filePath ?? this.filePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      capturedDate: capturedDate ?? this.capturedDate,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'module_id': moduleId,
      'file_path': filePath,
      'thumbnail_path': thumbnailPath,
      'captured_date': capturedDate.toIso8601String(),
      'note': note,
    };
  }

  factory BoardPhoto.fromMap(Map<String, dynamic> map) {
    return BoardPhoto(
      id: map['id'] as String,
      moduleId: map['module_id'] as String,
      filePath: map['file_path'] as String,
      thumbnailPath: map['thumbnail_path'] as String?,
      capturedDate: DateTime.parse(map['captured_date'] as String),
      note: map['note'] as String?,
    );
  }
}
