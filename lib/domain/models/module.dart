import 'dart:ui';

class Module {
  final String id;
  final String code;
  final String name;
  final int credits;
  final String colorHex;
  final int plannedLectures;
  final bool isCompleted;
  final String? completedGrade;
  final String? plannedGrade;

  const Module({
    required this.id,
    required this.code,
    required this.name,
    required this.credits,
    this.colorHex = '#14213D',
    this.plannedLectures = 12,
    this.isCompleted = false,
    this.completedGrade,
    this.plannedGrade,
  });

  Color get color {
    final hex = colorHex.replaceFirst('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    return const Color(0xFF14213D);
  }

  Module copyWith({
    String? id,
    String? code,
    String? name,
    int? credits,
    String? colorHex,
    int? plannedLectures,
    bool? isCompleted,
    String? completedGrade,
    String? plannedGrade,
  }) {
    return Module(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      credits: credits ?? this.credits,
      colorHex: colorHex ?? this.colorHex,
      plannedLectures: plannedLectures ?? this.plannedLectures,
      isCompleted: isCompleted ?? this.isCompleted,
      completedGrade: completedGrade ?? this.completedGrade,
      plannedGrade: plannedGrade ?? this.plannedGrade,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'credits': credits,
      'color_hex': colorHex,
      'planned_lectures': plannedLectures,
      'is_completed': isCompleted ? 1 : 0,
      'completed_grade': completedGrade,
      'planned_grade': plannedGrade,
    };
  }

  factory Module.fromMap(Map<String, dynamic> map) {
    return Module(
      id: map['id'] as String,
      code: map['code'] as String,
      name: map['name'] as String,
      credits: (map['credits'] as num).toInt(),
      colorHex: (map['color_hex'] as String?) ?? '#14213D',
      plannedLectures: (map['planned_lectures'] as num?)?.toInt() ?? 12,
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
      completedGrade: map['completed_grade'] as String?,
      plannedGrade: map['planned_grade'] as String?,
    );
  }
}
