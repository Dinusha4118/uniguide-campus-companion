import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../../domain/models/academic_settings.dart';
import '../../widgets/primary_button.dart';

class AcademicRulesScreen extends ConsumerStatefulWidget {
  const AcademicRulesScreen({super.key});

  @override
  ConsumerState<AcademicRulesScreen> createState() => _AcademicRulesScreenState();
}

class _AcademicRulesScreenState extends ConsumerState<AcademicRulesScreen> {
  late double _minAttendance;
  late double _targetGpa;
  late Map<String, double> _gradeScale;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final academic = ref.read(settingsProvider).academicSettings;
      _minAttendance = academic.minAttendancePercent;
      _targetGpa = academic.targetGpa;
      _gradeScale = Map.from(academic.gradeScale);
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSi = settings.language == 'si';

    return Scaffold(
      backgroundColor: isDark ? AppColors.night : AppColors.softCloud,
      appBar: AppBar(
        title: Text(isSi ? 'අධ්‍යයන නීති' : 'Academic rules'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                final def = AcademicSettings.initial();
                _minAttendance = def.minAttendancePercent;
                _targetGpa = def.targetGpa;
                _gradeScale = Map.from(def.gradeScale);
              });
            },
            child: Text(
              isSi ? 'පෙරනිමි' : 'Reset defaults',
              style: const TextStyle(color: AppColors.campusOrange, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Minimum Attendance Slider Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDarkElevated : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isSi ? 'අවම පැමිණීමේ ප්‍රතිශතය' : 'Minimum attendance',
                          style: TextStyle(
                            fontFamily: AppTypography.interFont,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
                          ),
                        ),
                        Text(
                          '${_minAttendance.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontFamily: AppTypography.poppinsFont,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.campusOrange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isSi
                          ? 'විභාග සුදුසුකම් ලැබීමට අවශ්‍ය අවම ප්‍රතිශතය (සාමාන්‍යයෙන් 80%)'
                          : 'Minimum required for exam eligibility (standard is 80%).',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                      ),
                    ),
                    Slider(
                      value: _minAttendance,
                      min: 50,
                      max: 100,
                      divisions: 10,
                      activeColor: AppColors.campusOrange,
                      onChanged: (val) => setState(() => _minAttendance = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Target GPA Slider Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDarkElevated : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isSi ? 'ඉලක්ක GPA' : 'Target GPA goal',
                          style: TextStyle(
                            fontFamily: AppTypography.interFont,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
                          ),
                        ),
                        Text(
                          _targetGpa.toStringAsFixed(2),
                          style: const TextStyle(
                            fontFamily: AppTypography.poppinsFont,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.campusOrange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isSi
                          ? 'ඔබේ උපාධිය සඳහා අපේක්ෂිත සමස්ත GPA අගය'
                          : 'Cumulative GPA you are aiming to graduate with.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                      ),
                    ),
                    Slider(
                      value: _targetGpa,
                      min: 2.0,
                      max: 4.0,
                      divisions: 40,
                      activeColor: AppColors.campusOrange,
                      onChanged: (val) => setState(() => _targetGpa = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Grade Scale Customization Table
              Text(
                isSi ? 'ශ්‍රේණි ලකුණු පරිමාණය' : 'Grade point scale (GPA weight)',
                style: TextStyle(
                  fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.poppinsFont,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDarkElevated : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                child: Column(
                  children: _gradeScale.keys.map((grade) {
                    final points = _gradeScale[grade]!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 36,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.campusOrange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              grade,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.campusOrange,
                              ),
                            ),
                          ),
                          Text(
                            'Grade Point: ${points.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppColors.textDarkHigh : AppColors.ink,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            onPressed: () => _editGradePointDialog(context, grade, points),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),

              PrimaryButton(
                label: isSi ? 'නීති සුරකින්න' : 'Save academic rules',
                onPressed: () async {
                  final updated = AcademicSettings(
                    minAttendancePercent: _minAttendance,
                    targetGpa: _targetGpa,
                    gradeScale: _gradeScale,
                  );
                  await ref.read(settingsProvider.notifier).saveAcademicSettings(updated);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Academic rules saved!')),
                    );
                    context.pop();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editGradePointDialog(BuildContext context, String grade, double currentPoints) {
    final controller = TextEditingController(text: currentPoints.toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Points for $grade'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Grade Point (e.g. 3.70)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.campusOrange, foregroundColor: AppColors.deepNavy),
            onPressed: () {
              final val = double.tryParse(controller.text.trim());
              if (val != null && val >= 0 && val <= 4.0) {
                setState(() {
                  _gradeScale[grade] = val;
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
