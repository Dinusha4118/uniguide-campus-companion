import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../application/providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../../domain/models/module.dart';
import '../../../domain/models/class_session.dart';
import '../../../domain/models/attendance_record.dart';
import '../../../domain/calculations/timetable_calculator.dart';
import '../../../domain/calculations/attendance_calculator.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/status_card.dart';

class ClassesScreen extends ConsumerStatefulWidget {
  const ClassesScreen({super.key});

  @override
  ConsumerState<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends ConsumerState<ClassesScreen> {
  int _selectedSegment = 0; // 0 = Timetable, 1 = Attendance
  int _selectedDay = DateTime.now().weekday; // 1 = Mon ... 7 = Sun

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSi = settings.language == 'si';

    final modulesAsync = ref.watch(modulesProvider);
    final classesAsync = ref.watch(timetableProvider);
    final attendanceAsync = ref.watch(attendanceProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.night : AppColors.softCloud,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section: Title & Segmented Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedSegment == 0
                        ? (isSi ? 'ඔබේ දේශන' : 'Your classes')
                        : (isSi ? 'පැමිණීම පාලනය කරන්න' : 'Stay on track'),
                    style: TextStyle(
                      fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.poppinsFont,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _selectedSegment == 0
                        ? DateFormat('d MMMM – ').format(DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1))) +
                            DateFormat('d MMMM').format(DateTime.now().add(Duration(days: 7 - DateTime.now().weekday)))
                        : (isSi
                            ? 'ඔබේ අවම පැමිණීම: ${settings.academicSettings.minAttendancePercent.toStringAsFixed(0)}% · සැකසුම් මඟින් වෙනස් කරන්න'
                            : 'Your minimum attendance: ${settings.academicSettings.minAttendancePercent.toStringAsFixed(0)}% · Edit in Settings'),
                    style: TextStyle(
                      fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.interFont,
                      fontSize: 13,
                      color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Segmented control [ Timetable  /  Attendance ]
                  Container(
                    height: 44,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDarkElevated : const Color(0xFFE5E9F2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildSegmentButton(
                            label: isSi ? 'කාල සටහන' : 'Timetable',
                            isSelected: _selectedSegment == 0,
                            onTap: () => setState(() => _selectedSegment = 0),
                            isDark: isDark,
                          ),
                        ),
                        Expanded(
                          child: _buildSegmentButton(
                            label: isSi ? 'පැමිණීම' : 'Attendance',
                            isSelected: _selectedSegment == 1,
                            onTap: () => setState(() => _selectedSegment = 1),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: _selectedSegment == 0
                  ? _buildTimetableView(modulesAsync, classesAsync, isDark, isSi)
                  : _buildAttendanceView(modulesAsync, attendanceAsync, isDark, isSi),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.cardDark : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.poppinsFont,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? (isDark ? AppColors.campusOrange : AppColors.deepNavy)
                : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
          ),
        ),
      ),
    );
  }

  // --- 1. Timetable View ---
  Widget _buildTimetableView(
    AsyncValue<List<Module>> modulesAsync,
    AsyncValue<List<ClassSession>> classesAsync,
    bool isDark,
    bool isSi,
  ) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    return classesAsync.when(
      data: (allClasses) {
        final dayClasses = allClasses.where((c) => c.dayOfWeek == _selectedDay).toList()
          ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));

        final freeGaps = TimetableCalculator.calculateFreeTimeGaps(dayClasses);
        final overlaps = TimetableCalculator.detectOverlaps(dayClasses);

        return Column(
          children: [
            // Weekday Strip (Monday - Sunday)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : const Color(0xFFFEF6E6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : const Color(0xFFFDE8C4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 6, bottom: 8),
                    child: Text(
                      'THIS WEEK · ${DateFormat('EEEE').format(monday.add(Duration(days: _selectedDay - 1))).toUpperCase()} SELECTED',
                      style: AppTypography.overlineBadge(
                        color: isDark ? AppColors.campusOrange : const Color(0xFF946200),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(7, (i) {
                      final dayNum = i + 1;
                      final dayDate = monday.add(Duration(days: i));
                      final isSelected = _selectedDay == dayNum;

                      return InkWell(
                        onTap: () => setState(() => _selectedDay = dayNum),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.campusOrange : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Text(
                                days[i],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isSelected
                                      ? AppColors.deepNavy
                                      : (isDark ? Colors.white : AppColors.ink),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${dayDate.day}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                  color: isSelected
                                      ? AppColors.deepNavy
                                      : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Class list for selected day
            Expanded(
              child: dayClasses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_available_rounded,
                            size: 48,
                            color: isDark ? AppColors.textDarkMuted : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isSi ? 'මෙම දිනය සඳහා දේශන නොමැත' : 'No classes for this day',
                            style: TextStyle(
                              fontFamily: AppTypography.poppinsFont,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textDarkHigh : AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isSi ? 'පහත බොත්තම මඟින් දේශනයක් එක් කරන්න' : 'Use the button below to add a class.',
                            style: TextStyle(
                              fontFamily: AppTypography.interFont,
                              fontSize: 13,
                              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: dayClasses.length * 2 - 1,
                      itemBuilder: (context, idx) {
                        // Alternate between class card and free time gap
                        if (idx.isEven) {
                          final classIdx = idx ~/ 2;
                          final cls = dayClasses[classIdx];
                          final mod = modulesAsync.value?.cast().firstWhere(
                                (m) => m.id == cls.moduleId,
                                orElse: () => null,
                              );

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.cardDark : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cls.type.toUpperCase(),
                                        style: AppTypography.overlineBadge(color: AppColors.campusOrange),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        mod?.name ?? cls.type,
                                        style: TextStyle(
                                          fontFamily: AppTypography.poppinsFont,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? AppColors.textDarkHigh : AppColors.ink,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${cls.startTime}–${cls.endTime} · ${cls.room}',
                                        style: TextStyle(
                                          fontFamily: AppTypography.interFont,
                                          fontSize: 13,
                                          color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                                  onPressed: () => ref.read(timetableProvider.notifier).deleteClass(cls.id),
                                  tooltip: 'Delete class',
                                ),
                              ],
                            ),
                          );
                        } else {
                          // Free time gap
                          final gapIdx = idx ~/ 2;
                          if (gapIdx < freeGaps.length) {
                            final gap = freeGaps[gapIdx];
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.safeGreenDarkTint : const Color(0xFFEBF8F6),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.wb_sunny_rounded, size: 16, color: AppColors.mintSuccess),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'FREE TIME: ${gap.formattedDuration} (${gap.start}–${gap.end})',
                                      style: TextStyle(
                                        fontFamily: AppTypography.interFont,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        color: isDark ? AppColors.mintSuccess : AppColors.safeGreenText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }
                      },
                    ),
            ),

            // Bottom Add Class Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: PrimaryButton(
                label: isSi ? '+ දේශනයක් එක් කරන්න' : '+ Add class',
                onPressed: () => context.push('/classes/add'),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  // --- 2. Attendance View ---
  Widget _buildAttendanceView(
    AsyncValue<List<Module>> modulesAsync,
    AsyncValue<List<AttendanceRecord>> attendanceAsync,
    bool isDark,
    bool isSi,
  ) {
    final settings = ref.watch(settingsProvider);

    return modulesAsync.when(
      data: (modules) {
        if (modules.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.library_books_rounded, size: 48, color: AppColors.campusOrange),
                const SizedBox(height: 12),
                Text(
                  isSi ? 'විෂයයන් හමු නොවීය' : 'No modules found',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(isSi ? 'සැකසුම් මඟින් විෂයයන් එක් කරන්න' : 'Add modules in Settings or Setup Wizard.'),
              ],
            ),
          );
        }

        final records = attendanceAsync.value ?? [];

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          itemCount: modules.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, idx) {
            final mod = modules[idx];
            final modRecords = records.where((r) => r.moduleId == mod.id).toList();
            final attended = modRecords.where((r) => r.isAttended).length;
            final missed = modRecords.where((r) => !r.isAttended).length;

            final result = AttendanceCalculator.calculateSafeSkips(
              attended: attended,
              missed: missed,
              plannedLectures: mod.plannedLectures,
              minAttendanceFraction: settings.academicSettings.minAttendancePercent / 100.0,
            );

            return StatusCard(
              status: result.status,
              title: '${mod.name} · ${result.currentPercentage != null ? "${result.currentPercentage!.toStringAsFixed(0)}%" : "New"}',
              subtitle: '${result.attended} / ${result.recordedLectures} attended · ${result.remainingLectures} left\n${result.descriptionText}',
              trailing: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: Text(isSi ? 'පැමිණියා' : 'Attended'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mintSuccess,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          ref.read(attendanceProvider.notifier).record(
                                moduleId: mod.id,
                                isAttended: true,
                              );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: Text(isSi ? 'නොපැමිණියා' : 'Missed'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? AppColors.textDarkHigh : AppColors.ink,
                          side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          ref.read(attendanceProvider.notifier).record(
                                moduleId: mod.id,
                                isAttended: false,
                              );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                context.push('/classes/attendance/${mod.id}');
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
