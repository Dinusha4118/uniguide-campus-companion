import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../application/providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../../domain/models/module.dart';
import '../../widgets/primary_button.dart';

class ManageModulesScreen extends ConsumerWidget {
  const ManageModulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSi = settings.language == 'si';

    final modulesAsync = ref.watch(modulesProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.night : AppColors.softCloud,
      appBar: AppBar(
        title: Text(isSi ? 'විෂයයන් කළමනාකරණය' : 'Manage modules'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: modulesAsync.when(
                data: (modules) {
                  if (modules.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.library_books_rounded, size: 48, color: AppColors.campusOrange),
                          const SizedBox(height: 12),
                          Text(
                            isSi ? 'කිසිදු විෂයයක් එක් කර නොමැත' : 'No modules configured yet',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isSi ? 'නව විෂයයක් එක් කිරීමට පහත බොත්තම ඔබන්න.' : 'Tap "+ Add module" below to start.',
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: modules.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) {
                      final m = modules[idx];
                      final color = Color(int.parse((m.colorHex ?? '#FCA311').replaceFirst('#', '0xFF')));

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDarkElevated : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m.name,
                                    style: TextStyle(
                                      fontFamily: AppTypography.interFont,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${m.code} · ${m.credits} Credits · ${m.plannedLectures != null ? "${m.plannedLectures} planned" : "No plan set"}',
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
                              onPressed: () => _showAddEditModuleDialog(context, ref, module: m),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.alertRed, size: 20),
                              onPressed: () => _confirmDeleteModule(context, ref, m),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: PrimaryButton(
                label: isSi ? '+ නව විෂයයක් එක් කරන්න' : '+ Add module',
                onPressed: () => _showAddEditModuleDialog(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEditModuleDialog(BuildContext context, WidgetRef ref, {Module? module}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameCtrl = TextEditingController(text: module?.name ?? '');
    final codeCtrl = TextEditingController(text: module?.code ?? '');
    final creditsCtrl = TextEditingController(text: module?.credits.toString() ?? '3');
    final plannedCtrl = TextEditingController(text: module != null ? '${module.plannedLectures}' : '12');

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDarkElevated : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(module != null ? 'Edit Module' : 'Add Module'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Module Name (e.g. Computer Networks)'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(labelText: 'Module Code (e.g. IT2030)'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: creditsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Credit Value (e.g. 3 or 4)'),
                  validator: (v) {
                    final val = int.tryParse(v ?? '');
                    if (val == null || val <= 0) return 'Must be positive credits';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: plannedCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Planned Total Lectures (e.g. 12)'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.campusOrange, foregroundColor: AppColors.deepNavy),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final name = nameCtrl.text.trim();
              final code = codeCtrl.text.trim();
              final credits = int.parse(creditsCtrl.text.trim());
              final planned = int.tryParse(plannedCtrl.text.trim()) ?? 12;

              if (module != null) {
                final updated = module.copyWith(
                  name: name,
                  code: code,
                  credits: credits,
                  plannedLectures: planned,
                );
                await ref.read(modulesProvider.notifier).updateModule(updated);
              } else {
                final newMod = Module(
                  id: const Uuid().v4(),
                  name: name,
                  code: code,
                  credits: credits,
                  plannedLectures: planned,
                  colorHex: '#FCA311',
                );
                await ref.read(modulesProvider.notifier).addModule(newMod);
              }

              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteModule(BuildContext context, WidgetRef ref, Module module) async {
    final counts = await ref.read(modulesProvider.notifier).getAffectedCounts(module.id);
    final classesCount = counts['classes'] ?? 0;
    final attCount = counts['attendance'] ?? 0;
    final deadCount = counts['deadlines'] ?? 0;
    final photoCount = counts['photos'] ?? 0;

    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${module.code}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Deleting this module will permanently remove:'),
            const SizedBox(height: 8),
            Text('• $classesCount Timetable classes'),
            Text('• $attCount Attendance records'),
            Text('• $deadCount Deadlines'),
            Text('• $photoCount Board Snap photos'),
            const SizedBox(height: 16),
            const Text(
              'This action cannot be undone. Do you wish to continue?',
              style: TextStyle(color: AppColors.alertRed, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.alertRed, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete Module'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(modulesProvider.notifier).deleteModule(module.id);
      // Refresh linked providers
      ref.invalidate(timetableProvider);
      ref.invalidate(attendanceProvider);
      ref.invalidate(deadlinesProvider);
      ref.invalidate(boardPhotosProvider);
    }
  }
}
