import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../application/providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../../domain/models/deadline.dart';
import '../../widgets/primary_button.dart';

class AddDeadlineScreen extends ConsumerStatefulWidget {
  final String? editDeadlineId;

  const AddDeadlineScreen({super.key, this.editDeadlineId});

  @override
  ConsumerState<AddDeadlineScreen> createState() => _AddDeadlineScreenState();
}

class _AddDeadlineScreenState extends ConsumerState<AddDeadlineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedModuleId;
  String _selectedType = 'assignment';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 3));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 23, minute: 59);
  bool _initialized = false;

  final List<String> _types = ['assignment', 'quiz', 'viva', 'exam', 'other'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized && widget.editDeadlineId != null) {
      final deadlines = ref.read(deadlinesProvider).value ?? [];
      final deadline = deadlines.firstWhere(
        (d) => d.id == widget.editDeadlineId,
        orElse: () => throw Exception('Deadline not found'),
      );
      _titleController.text = deadline.title;
      _notesController.text = deadline.notes ?? '';
      _selectedModuleId = deadline.moduleId;
      _selectedType = deadline.type;
      _selectedDate = deadline.dueDateTime;
      _selectedTime = TimeOfDay(hour: deadline.dueDateTime.hour, minute: deadline.dueDateTime.minute);
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSi = settings.language == 'si';

    final modulesAsync = ref.watch(modulesProvider);
    final isEditing = widget.editDeadlineId != null;

    return Scaffold(
      backgroundColor: isDark ? AppColors.night : AppColors.softCloud,
      appBar: AppBar(
        title: Text(
          isEditing
              ? (isSi ? 'නියමිත කාර්යය සංස්කරණය' : 'Edit deadline')
              : (isSi ? 'නව නියමිත කාර්යයක්' : 'Add deadline'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.alertRed),
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      body: SafeArea(
        child: modulesAsync.when(
          data: (modules) {
            if (modules.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 48, color: AppColors.amberWarn),
                      const SizedBox(height: 16),
                      Text(
                        isSi ? 'පළමුව විෂයයක් එක් කරන්න' : 'Please add a module first',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isSi
                            ? 'නියමිත කාර්යයන් විෂයයන්ට සම්බන්ධ කළ යුතුය.'
                            : 'Deadlines must be linked to a module.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.push('/settings/modules'),
                        child: Text(isSi ? 'විෂයයන් වෙත' : 'Manage modules'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (_selectedModuleId == null && modules.isNotEmpty) {
              _selectedModuleId = modules.first.id;
            }

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: isSi ? 'ශීර්ෂය *' : 'Title *',
                        hintText: isSi ? 'උදා: Coursework 1 Report' : 'e.g. Coursework 1 Report',
                      ),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? (isSi ? 'ශීර්ෂයක් අවශ්‍යයි' : 'Please enter a title')
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Module Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedModuleId,
                      decoration: InputDecoration(
                        labelText: isSi ? 'විෂයය *' : 'Module *',
                      ),
                      items: modules.map((m) {
                        return DropdownMenuItem<String>(
                          value: m.id,
                          child: Text('${m.code} - ${m.name}'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedModuleId = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Type Chips
                    Text(
                      isSi ? 'වර්ගය' : 'Type',
                      style: TextStyle(
                        fontFamily: AppTypography.interFont,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _types.map((type) {
                        final isSel = _selectedType == type;
                        return ChoiceChip(
                          label: Text(type[0].toUpperCase() + type.substring(1)),
                          selected: isSel,
                          selectedColor: AppColors.campusOrange,
                          labelStyle: TextStyle(
                            color: isSel ? AppColors.deepNavy : (isDark ? AppColors.textDarkHigh : AppColors.ink),
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                          ),
                          onSelected: (_) => setState(() => _selectedType = type),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Due Date & Time Picker
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                              );
                              if (picked != null) {
                                setState(() => _selectedDate = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: isSi ? 'නියමිත දිනය' : 'Due date',
                                suffixIcon: const Icon(Icons.calendar_month_rounded, size: 20),
                              ),
                              child: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: _selectedTime,
                              );
                              if (picked != null) {
                                setState(() => _selectedTime = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: isSi ? 'වේලාව' : 'Due time',
                                suffixIcon: const Icon(Icons.access_time_rounded, size: 20),
                              ),
                              child: Text(_selectedTime.format(context)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: isSi ? 'සටහන් (විකල්ප)' : 'Notes (optional)',
                        hintText: isSi ? 'ගොනු ආකෘතිය, මාතෘකාව හෝ උපදෙස්' : 'Submission instructions, format, room etc.',
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    PrimaryButton(
                      label: isEditing
                          ? (isSi ? 'වෙනස්කම් සුරකින්න' : 'Save changes')
                          : (isSi ? 'නියමිත කාර්යය එක් කරන්න' : 'Save deadline'),
                      onPressed: _saveDeadline,
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Future<void> _saveDeadline() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedModuleId == null) return;

    final dueDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final deadline = Deadline(
      id: widget.editDeadlineId ?? const Uuid().v4(),
      moduleId: _selectedModuleId!,
      title: _titleController.text.trim(),
      dueDateTime: dueDateTime,
      type: _selectedType,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      isCompleted: false,
    );

    if (widget.editDeadlineId != null) {
      await ref.read(deadlinesProvider.notifier).updateDeadline(deadline);
    } else {
      await ref.read(deadlinesProvider.notifier).addDeadline(deadline);
    }

    if (mounted) {
      context.pop();
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Deadline?'),
        content: const Text('Are you sure you want to delete this deadline? Reminders will also be cancelled.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.alertRed, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.editDeadlineId != null) {
      await ref.read(deadlinesProvider.notifier).deleteDeadline(widget.editDeadlineId!);
      if (mounted) context.pop();
    }
  }
}
