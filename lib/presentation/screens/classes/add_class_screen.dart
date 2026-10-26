import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../../domain/models/class_session.dart';
import '../../widgets/primary_button.dart';

class AddClassScreen extends ConsumerStatefulWidget {
  const AddClassScreen({super.key});

  @override
  ConsumerState<AddClassScreen> createState() => _AddClassScreenState();
}

class _AddClassScreenState extends ConsumerState<AddClassScreen> {
  String? _selectedModuleId;
  int _selectedDay = 1;
  TimeOfDay _startTime = const TimeOfDay(hour: 10, minute: 30);
  TimeOfDay _endTime = const TimeOfDay(hour: 12, minute: 30);
  final _roomController = TextEditingController(text: 'Hall 301');
  String _selectedType = 'Lecture';
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _roomController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveClass() async {
    if (_selectedModuleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a module.')),
      );
      return;
    }

    final room = _roomController.text.trim();
    if (room.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a room or hall.')),
      );
      return;
    }

    final startStr = '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}';
    final endStr = '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}';

    final session = ClassSession(
      id: 'cls_${DateTime.now().millisecondsSinceEpoch}',
      moduleId: _selectedModuleId!,
      dayOfWeek: _selectedDay,
      startTime: startStr,
      endTime: endStr,
      room: room,
      type: _selectedType,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    await ref.read(timetableProvider.notifier).addClass(session);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final modules = ref.watch(modulesProvider).value ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    _selectedModuleId ??= modules.isNotEmpty ? modules.first.id : null;

    return Scaffold(
      backgroundColor: isDark ? AppColors.night : AppColors.softCloud,
      appBar: AppBar(
        title: const Text('Add Class'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Module Picker
              DropdownButtonFormField<String>(
                value: _selectedModuleId,
                decoration: const InputDecoration(labelText: 'Module'),
                items: modules.map((m) {
                  return DropdownMenuItem(value: m.id, child: Text('${m.code} - ${m.name}'));
                }).toList(),
                onChanged: (val) => setState(() => _selectedModuleId = val),
              ),
              const SizedBox(height: 16),

              // Day Picker
              DropdownButtonFormField<int>(
                value: _selectedDay,
                decoration: const InputDecoration(labelText: 'Day of Week'),
                items: List.generate(7, (i) {
                  return DropdownMenuItem(value: i + 1, child: Text(days[i]));
                }),
                onChanged: (val) => setState(() => _selectedDay = val ?? 1),
              ),
              const SizedBox(height: 16),

              // Time pickers
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(context: context, initialTime: _startTime);
                        if (picked != null) setState(() => _startTime = picked);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Start Time'),
                        child: Text(_startTime.format(context)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(context: context, initialTime: _endTime);
                        if (picked != null) setState(() => _endTime = picked);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'End Time'),
                        child: Text(_endTime.format(context)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _roomController,
                decoration: const InputDecoration(labelText: 'Hall or Room', hintText: 'e.g. Hall 301 or Lab 3'),
              ),
              const SizedBox(height: 16),

              // Class Type
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Class Type'),
                items: ['Lecture', 'Lab', 'Tutorial', 'Workshop'].map((t) {
                  return DropdownMenuItem(value: t, child: Text(t));
                }).toList(),
                onChanged: (val) => setState(() => _selectedType = val ?? 'Lecture'),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Notes (optional)', hintText: 'e.g. Bring lab sheet'),
              ),
              const SizedBox(height: 28),

              PrimaryButton(
                label: 'Save Class',
                onPressed: _saveClass,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
