import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../application/providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/brand_logo_widget.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSi = settings.language == 'si';

    return Scaffold(
      backgroundColor: isDark ? AppColors.night : AppColors.softCloud,
      appBar: AppBar(
        title: Text(isSi ? 'සැකසුම්' : 'Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          children: [
            // Student Profile Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDarkElevated : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppColors.campusOrange,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        settings.studentName.isNotEmpty ? settings.studentName[0].toUpperCase() : 'S',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepNavy,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          settings.studentName,
                          style: TextStyle(
                            fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.poppinsFont,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
                          ),
                        ),
                        Text(
                          isSi ? 'ශිෂ්‍ය ගිණුම (නොබැඳි)' : 'Offline Student Profile',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => _editNameDialog(context, ref, settings.studentName),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section: Preferences
            _buildSectionHeader(isSi ? 'මනාප සහ පෙනුම' : 'Preferences', isDark, isSi),
            const SizedBox(height: 8),
            _buildSettingsCard(
              isDark: isDark,
              children: [
                // Language
                ListTile(
                  leading: const Icon(Icons.language_rounded, color: AppColors.campusOrange),
                  title: Text(isSi ? 'භාෂාව' : 'Language'),
                  subtitle: Text(settings.language == 'si' ? 'සිංහල (Sinhala)' : 'English'),
                  trailing: DropdownButton<String>(
                    value: settings.language,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'si', child: Text('සිංහල')),
                    ],
                    onChanged: (val) {
                      if (val != null) settingsNotifier.setLanguage(val);
                    },
                  ),
                ),
                Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),

                // Appearance
                ListTile(
                  leading: const Icon(Icons.palette_outlined, color: AppColors.campusOrange),
                  title: Text(isSi ? 'තේමාව' : 'Appearance'),
                  subtitle: Text(_getThemeName(settings.themeMode)),
                  trailing: DropdownButton<ThemeMode>(
                    value: settings.themeMode,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                      DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                      DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                    ],
                    onChanged: (val) {
                      if (val != null) settingsNotifier.setThemeMode(val);
                    },
                  ),
                ),
                Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),

                // Notifications
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_active_outlined, color: AppColors.campusOrange),
                  title: Text(isSi ? 'දේශන සහ කාර්ය සිහිකැඳවීම්' : 'Class & Deadline Reminders'),
                  subtitle: Text(isSi ? 'නොබැඳි දේශීය දැනුම්දීම්' : 'Offline local notifications'),
                  value: settings.remindersEnabled,
                  onChanged: (val) => settingsNotifier.setRemindersEnabled(val),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Section: Academic Setup
            _buildSectionHeader(isSi ? 'අධ්‍යයන සැකසුම්' : 'Academic Setup', isDark, isSi),
            const SizedBox(height: 8),
            _buildSettingsCard(
              isDark: isDark,
              children: [
                ListTile(
                  leading: const Icon(Icons.school_outlined, color: AppColors.campusOrange),
                  title: Text(isSi ? 'අධ්‍යයන නීති සහ ශ්‍රේණි ක්‍රමය' : 'Academic rules & grade scale'),
                  subtitle: Text('${settings.academicSettings.minAttendancePercent.toStringAsFixed(0)}% attendance · Target ${settings.academicSettings.targetGpa.toStringAsFixed(2)} GPA'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/settings/academic-rules'),
                ),
                Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ListTile(
                  leading: const Icon(Icons.library_books_outlined, color: AppColors.campusOrange),
                  title: Text(isSi ? 'විෂයයන් කළමනාකරණය' : 'Manage modules'),
                  subtitle: Text(isSi ? 'විෂයයන් එක් කරන්න, සංස්කරණය හෝ මකන්න' : 'Add, edit, or remove semester modules'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/settings/modules'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Section: Data & Privacy
            _buildSectionHeader(isSi ? 'දත්ත සහ උපස්ථ' : 'Data & Privacy', isDark, isSi),
            const SizedBox(height: 8),
            _buildSettingsCard(
              isDark: isDark,
              children: [
                ListTile(
                  leading: const Icon(Icons.upload_file_rounded, color: AppColors.mintSuccess),
                  title: Text(isSi ? 'දත්ත උපස්ථය අපනයනය කරන්න' : 'Export data backup'),
                  subtitle: Text(isSi ? 'සියලු දත්ත සහ ඡායාරූප ZIP ගොනුවක් ලෙස සුරකින්න' : 'Create a portable offline ZIP archive'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () => _exportBackup(context, ref),
                ),
                Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ListTile(
                  leading: const Icon(Icons.download_rounded, color: AppColors.campusOrange),
                  title: Text(isSi ? 'දත්ත උපස්ථයෙන් ප්‍රතිසාධනය කරන්න' : 'Restore from backup'),
                  subtitle: Text(isSi ? 'ZIP ගොනුවකින් පෙර දත්ත නැවත ලබාගන්න' : 'Import ZIP file with preview and validation'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () => _importBackup(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Disclaimer & About Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDarkElevated : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const BrandLogoWidget(size: 36),
                  const SizedBox(height: 8),
                  Text(
                    'UniGuide v1.0.0',
                    style: TextStyle(
                      fontFamily: AppTypography.poppinsFont,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '“Know where you stand. Plan what’s next.”',
                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.night : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isSi
                          ? 'නිල නොවන ශිෂ්‍ය සහායකයෙකි. සැමවිටම නිල විශ්වවිද්‍යාල තොරතුරු මූලාශ්‍ර මඟින් තහවුරු කරගන්න. සියලුම දත්ත ඔබගේ උපාංගය තුළ පමණක් සුරක්ෂිතව පවතී.'
                          : 'Unofficial student tool. Always confirm with official university sources. 100% offline — your data stays solely on this device.',
                      style: TextStyle(
                        fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.interFont,
                        fontSize: 11,
                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark, bool isSi) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.poppinsFont,
        fontWeight: FontWeight.w700,
        fontSize: 14,
        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
      ),
    );
  }

  Widget _buildSettingsCard({required bool isDark, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDarkElevated : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(children: children),
    );
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light theme';
      case ThemeMode.dark:
        return 'Dark theme';
      case ThemeMode.system:
        return 'System default';
    }
  }

  void _editNameDialog(BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Student Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.campusOrange, foregroundColor: AppColors.deepNavy),
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await ref.read(settingsProvider.notifier).setStudentName(controller.text.trim());
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportBackup(BuildContext context, WidgetRef ref) async {
    try {
      final backupService = ref.read(backupServiceProvider);
      final zipPath = await backupService.exportBackup();
      final file = XFile(zipPath);

      await Share.shareXFiles([file], text: 'UniGuide Data Backup');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup exported successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _importBackup(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePickerPlatform.instance.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result == null || result.isEmpty || result.first.path == null) return;
      final path = result.first.path!;

      final backupService = ref.read(backupServiceProvider);
      final preview = await backupService.previewBackup(path);

      if (!context.mounted) return;

      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Restore Backup?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('This backup archive contains:'),
              const SizedBox(height: 8),
              Text('• ${preview.moduleCount} Modules'),
              Text('• ${preview.classCount} Timetable Classes'),
              Text('• ${preview.attendanceCount} Attendance Records'),
              Text('• ${preview.deadlineCount} Deadlines'),
              Text('• ${preview.studySessionCount} Focus Study Sessions'),
              Text('• ${preview.photoCount} Board Snap Photos'),
              const SizedBox(height: 16),
              const Text(
                'Warning: Restoring will overwrite current data. Do you wish to proceed?',
                style: TextStyle(color: AppColors.alertRed, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.alertRed, foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Restore Data'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await backupService.restoreBackup(path);
        // Refresh all providers
        ref.invalidate(modulesProvider);
        ref.invalidate(timetableProvider);
        ref.invalidate(attendanceProvider);
        ref.invalidate(deadlinesProvider);
        ref.invalidate(studySessionsProvider);
        ref.invalidate(boardPhotosProvider);
        await ref.read(settingsProvider.notifier).loadSettings();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Backup restored successfully!')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: $e')),
        );
      }
    }
  }
}
