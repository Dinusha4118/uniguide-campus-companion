import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../application/providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../../domain/calculations/attendance_calculator.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/status_card.dart';

class AttendanceDetailScreen extends ConsumerWidget {
  final String moduleId;

  const AttendanceDetailScreen({super.key, required this.moduleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSi = settings.language == 'si';

    final modulesAsync = ref.watch(modulesProvider);
    final attendanceAsync = ref.watch(attendanceProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.night : AppColors.softCloud,
      appBar: AppBar(
        title: Text(isSi ? 'පැමිණීමේ විස්තර' : 'Attendance details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy),
          onPressed: () => context.pop(),
        ),
      ),
      body: modulesAsync.when(
        data: (modules) {
          final mod = modules.firstWhere(
            (m) => m.id == moduleId,
            orElse: () => throw Exception('Module not found'),
          );

          final records = (attendanceAsync.value ?? [])
              .where((r) => r.moduleId == moduleId)
              .toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          final attended = records.where((r) => r.isAttended).length;
          final missed = records.where((r) => !r.isAttended).length;

          final calc = AttendanceCalculator.calculateSafeSkips(
            attended: attended,
            missed: missed,
            plannedLectures: mod.plannedLectures,
            minAttendanceFraction: settings.academicSettings.minAttendancePercent / 100.0,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Module Header Card
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mod.name,
                                  style: TextStyle(
                                    fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.poppinsFont,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${mod.code} · ${mod.credits} ${isSi ? "බැර" : "Credits"} · ${mod.plannedLectures != null ? "${mod.plannedLectures} ${isSi ? "සැලසුම් කළ දේශන" : "planned"}" : (isSi ? "සැලසුම් කළ දේශන නොමැත" : "No planned total")}',
                                  style: TextStyle(
                                    fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.interFont,
                                    fontSize: 13,
                                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: AppColors.campusOrange),
                            onPressed: () => _showEditPlannedLecturesDialog(context, ref, mod),
                            tooltip: isSi ? 'සැලසුම් කළ දේශන සංස්කරණය' : 'Edit planned lectures',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Status & Calculation Overview
                      StatusCard(
                        status: calc.status,
                        title: calc.currentPercentage != null
                            ? '${calc.currentPercentage!.toStringAsFixed(1)}% ${isSi ? "වත්මන් පැමිණීම" : "Current Attendance"}'
                            : (isSi ? 'පැමිණීම් සටහන් කර නොමැත' : 'No attendance recorded yet'),
                        subtitle: calc.descriptionText,
                        badgeText: calc.safeAdditionalMisses != null
                            ? '${calc.safeAdditionalMisses} ${isSi ? "ඉතිරි මඟහැරීම්" : "safe skips"}'
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Record Today's Lecture Actions
                Text(
                  isSi ? 'අද දින පැමිණීම සලකුණු කරන්න' : 'Record for today',
                  style: TextStyle(
                    fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.poppinsFont,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle_rounded, size: 20),
                          label: Text(isSi ? 'පැමිණියා' : 'Attended'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.mintSuccess,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          onPressed: () async {
                            await ref.read(attendanceProvider.notifier).record(
                                  moduleId: mod.id,
                                  isAttended: true,
                                );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isSi ? 'පැමිණීම සටහන් විය' : 'Marked as attended!'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.cancel_rounded, size: 20),
                          label: Text(isSi ? 'නොපැමිණියා' : 'Missed'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.alertRed,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          onPressed: () async {
                            await ref.read(attendanceProvider.notifier).record(
                                  moduleId: mod.id,
                                  isAttended: false,
                                );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isSi ? 'නොපැමිණි බව සටහන් විය' : 'Marked as missed!'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // History Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isSi ? 'පැමිණීමේ ඉතිහාසය' : 'Attendance history',
                      style: TextStyle(
                        fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.poppinsFont,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
                      ),
                    ),
                    Text(
                      '${records.length} ${isSi ? "වාර්තා" : "sessions"}',
                      style: TextStyle(
                        fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.interFont,
                        fontSize: 13,
                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (records.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDarkElevated : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.event_note_rounded, size: 40, color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                          const SizedBox(height: 8),
                          Text(
                            isSi ? 'කිසිදු වාර්තාවක් නොමැත' : 'No recorded sessions yet',
                            style: TextStyle(
                              fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.interFont,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: records.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, idx) {
                      final rec = records[idx];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDarkElevated : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: rec.isAttended
                                    ? (isDark ? AppColors.safeGreenDarkTint : const Color(0xFFEBF8F6))
                                    : (isDark ? AppColors.alertRedDarkTint : const Color(0xFFFDECEC)),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                rec.isAttended ? Icons.check_rounded : Icons.close_rounded,
                                color: rec.isAttended ? AppColors.mintSuccess : AppColors.alertRed,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    rec.lectureDate,
                                    style: TextStyle(
                                      fontFamily: AppTypography.interFont,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('h:mm a').format(rec.timestamp),
                                    style: TextStyle(
                                      fontFamily: AppTypography.interFont,
                                      fontSize: 12,
                                      color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.undo_rounded, size: 20),
                              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                              tooltip: isSi ? 'ඉවත් කරන්න' : 'Undo record',
                              onPressed: () async {
                                await ref.read(attendanceProvider.notifier).undo(rec.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(isSi ? 'වාර්තාව ඉවත් කරන ලදී' : 'Record undone'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showEditPlannedLecturesDialog(BuildContext context, WidgetRef ref, dynamic mod) {
    final controller = TextEditingController(text: mod.plannedLectures?.toString() ?? '');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDarkElevated : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Planned Lectures'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set the total number of lectures planned for this semester to calculate your safe-skip allowance.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Total Planned Lectures (e.g. 12)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.campusOrange,
              foregroundColor: AppColors.deepNavy,
            ),
            onPressed: () async {
              final val = int.tryParse(controller.text.trim());
              if (val != null && val > 0) {
                final updated = mod.copyWith(plannedLectures: val);
                await ref.read(modulesProvider.notifier).updateModule(updated);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
