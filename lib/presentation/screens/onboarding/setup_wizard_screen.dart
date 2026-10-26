import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../../domain/models/module.dart';
import '../../../domain/models/class_session.dart';
import '../../widgets/primary_button.dart';

class SetupWizardScreen extends ConsumerStatefulWidget {
  const SetupWizardScreen({super.key});

  @override
  ConsumerState<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends ConsumerState<SetupWizardScreen> {
  int _step = 1; // 1 = Modules, 2 = Timetable

  // Module form fields
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _creditsController = TextEditingController(text: '4');
  final _plannedController = TextEditingController(text: '12');

  // Timetable form fields
  int _selectedDay = 1; // Monday
  TimeOfDay _startTime = const TimeOfDay(hour: 10, minute: 30);
  TimeOfDay _endTime = const TimeOfDay(hour: 12, minute: 30);
  final _roomController = TextEditingController(text: 'Hall 301');
  String? _selectedModuleId;

  final List<Module> _createdModules = [];
  final List<ClassSession> _createdClasses = [];

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _creditsController.dispose();
    _plannedController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  void _addModuleToList() {
    final code = _codeController.text.trim();
    final name = _nameController.text.trim();
    final credits = int.tryParse(_creditsController.text.trim()) ?? 0;
    final planned = int.tryParse(_plannedController.text.trim()) ?? 12;

    if (code.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both module code and name.')),
      );
      return;
    }

    if (credits <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credits must be a positive number.')),
      );
      return;
    }

    final id = 'mod_${code.toLowerCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}';
    final mod = Module(
      id: id,
      code: code,
      name: name,
      credits: credits,
      plannedLectures: planned,
      colorHex: '#14213D',
    );

    setState(() {
      _createdModules.add(mod);
      _selectedModuleId ??= mod.id;
      _codeController.clear();
      _nameController.clear();
      _creditsController.text = '4';
      _plannedController.text = '12';
    });
  }

  void _addClassToList() {
    if (_selectedModuleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a module for this class.')),
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

    final cls = ClassSession(
      id: 'class_${DateTime.now().millisecondsSinceEpoch}',
      moduleId: _selectedModuleId!,
      dayOfWeek: _selectedDay,
      startTime: startStr,
      endTime: endStr,
      room: room,
      type: 'Lecture',
    );

    setState(() {
      _createdClasses.add(cls);
    });
  }

  Future<void> _finishSetup() async {
    // 1. Save all created modules to database
    for (final mod in _createdModules) {
      await ref.read(modulesProvider.notifier).addModule(mod);
    }

    // 2. Save all created classes to database
    for (final cls in _createdClasses) {
      await ref.read(timetableProvider.notifier).addClass(cls);
    }

    // 3. Mark onboarding as completed
    await ref.read(settingsProvider.notifier).setOnboardingCompleted(true);

    if (mounted) {
      context.go('/home');
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
        title: Text(
          _step == 1
              ? (isSi ? 'විෂයයන් ඇතුළත් කිරීම (1/2)' : 'Add Modules (1/2)')
              : (isSi ? 'කාල සටහන සැකසීම (2/2)' : 'Set Timetable (2/2)'),
        ),
        actions: [
          TextButton(
            onPressed: _finishSetup,
            child: Text(
              isSi ? 'අවසන් කරන්න' : 'Finish',
              style: const TextStyle(
                fontFamily: AppTypography.poppinsFont,
                fontWeight: FontWeight.w700,
                color: AppColors.campusOrange,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              // Progress Bar
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _step == 1 ? 0.5 : 1.0,
                backgroundColor: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.campusOrange),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: _step == 1
                    ? _buildModulesStep(isDark, isSi)
                    : _buildTimetableStep(isDark, isSi),
              ),

              // Bottom Button Row
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  children: [
                    if (_step == 2) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _step = 1),
                          child: Text(isSi ? 'ආපසු' : 'Back'),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: 2,
                      child: PrimaryButton(
                        label: _step == 1
                            ? (isSi ? 'ඊළඟ: කාල සටහන' : 'Next: Timetable')
                            : (isSi ? 'මුල් පිටුවට යන්න' : 'Complete Setup'),
                        onPressed: () {
                          if (_step == 1) {
                            if (_createdModules.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please add at least one module or tap Finish to skip.')),
                              );
                              return;
                            }
                            setState(() => _step = 2);
                          } else {
                            _finishSetup();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModulesStep(bool isDark, bool isSi) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isSi ? 'ඔබගේ වත්මන් විෂයයන්' : 'Enter your semester modules',
            style: TextStyle(
              fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.poppinsFont,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isSi ? 'නම, කේතය සහ ණය ඒකක ඇතුළත් කරන්න.' : 'You can add more modules or edit them anytime later.',
            style: TextStyle(
              fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.interFont,
              fontSize: 14,
              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
            ),
          ),
          const SizedBox(height: 18),

          // Module Form Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Module Code',
                    hintText: 'e.g. IT1010',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Module Name',
                    hintText: 'e.g. Programming',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _creditsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Credits',
                          hintText: '4',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _plannedController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Planned Lectures',
                          hintText: '12',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addModuleToList,
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: Text(isSi ? 'විෂය එකතු කරන්න' : 'Add Module'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.deepNavy,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Added Modules List
          if (_createdModules.isNotEmpty) ...[
            Text(
              'Added Modules (${_createdModules.length})',
              style: TextStyle(
                fontFamily: AppTypography.poppinsFont,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
              ),
            ),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _createdModules.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, idx) {
                final m = _createdModules[idx];
                return ListTile(
                  tileColor: isDark ? AppColors.cardDarkElevated : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.campusOrange.withOpacity(0.2),
                    child: Text(
                      '${m.credits}C',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.campusOrange, fontSize: 13),
                    ),
                  ),
                  title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${m.code} · ${m.plannedLectures} lectures planned'),
                  trailing: IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () {
                      setState(() {
                        _createdModules.removeAt(idx);
                        if (_selectedModuleId == m.id) {
                          _selectedModuleId = _createdModules.isNotEmpty ? _createdModules.first.id : null;
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimetableStep(bool isDark, bool isSi) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isSi ? 'සතිපතා දේශන කාල සටහන' : 'Weekly timetable setup',
            style: TextStyle(
              fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.poppinsFont,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isSi ? 'සෑම සතියකම පැවැත්වෙන දේශන ඇතුළත් කරන්න.' : 'Add your recurring weekly lectures and labs.',
            style: TextStyle(
              fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.interFont,
              fontSize: 14,
              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
            ),
          ),
          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Module Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedModuleId,
                  decoration: const InputDecoration(labelText: 'Select Module'),
                  items: _createdModules.map((m) {
                    return DropdownMenuItem(
                      value: m.id,
                      child: Text('${m.code} - ${m.name}'),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedModuleId = val),
                ),
                const SizedBox(height: 14),

                // Day of Week Selector
                const Text('Day of Week', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (i) {
                    final dayNum = i + 1;
                    final isSel = _selectedDay == dayNum;
                    return InkWell(
                      onTap: () => setState(() => _selectedDay = dayNum),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.campusOrange : (isDark ? AppColors.cardDarkElevated : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          days[i],
                          style: TextStyle(
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            color: isSel ? AppColors.deepNavy : (isDark ? Colors.white : AppColors.ink),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 14),

                // Time Pickers
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
                const SizedBox(height: 14),

                TextField(
                  controller: _roomController,
                  decoration: const InputDecoration(
                    labelText: 'Room / Hall',
                    hintText: 'e.g. Hall 301 or Lab 3',
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addClassToList,
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: Text(isSi ? 'දේශනය කාල සටහනට එක් කරන්න' : 'Add Class to Timetable'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.deepNavy,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (_createdClasses.isNotEmpty) ...[
            Text(
              'Added Classes (${_createdClasses.length})',
              style: TextStyle(
                fontFamily: AppTypography.poppinsFont,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
              ),
            ),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _createdClasses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, idx) {
                final c = _createdClasses[idx];
                final mod = _createdModules.firstWhere((m) => m.id == c.moduleId);
                return ListTile(
                  tileColor: isDark ? AppColors.cardDarkElevated : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                  title: Text('${mod.code} - ${mod.name}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${days[c.dayOfWeek - 1]} ${c.startTime}–${c.endTime} · ${c.room}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => setState(() => _createdClasses.removeAt(idx)),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
