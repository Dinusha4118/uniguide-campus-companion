import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../../../application/providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../../domain/models/board_photo.dart';
import '../../widgets/primary_button.dart';

class BoardCaptureScreen extends ConsumerStatefulWidget {
  const BoardCaptureScreen({super.key});

  @override
  ConsumerState<BoardCaptureScreen> createState() => _BoardCaptureScreenState();
}

class _BoardCaptureScreenState extends ConsumerState<BoardCaptureScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraReady = false;
  bool _cameraPermissionDenied = false;

  XFile? _capturedFile;
  String? _selectedModuleId;
  DateTime _selectedDate = DateTime.now();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras!.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraReady = true;
          });
        }
      } else {
        if (mounted) setState(() => _isCameraReady = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cameraPermissionDenied = true;
          _isCameraReady = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSi = settings.language == 'si';

    final modulesAsync = ref.watch(modulesProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.night : AppColors.softCloud,
      appBar: AppBar(
        title: Text(isSi ? 'දේශන සටහනක් ගන්න' : 'Board Snap Capture'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: modulesAsync.when(
          data: (modules) {
            if (_selectedModuleId == null && modules.isNotEmpty) {
              _selectedModuleId = modules.first.id;
            }

            if (_capturedFile != null) {
              return _buildPreviewAndSaveForm(modules, isDark, isSi);
            }

            return _buildCameraView(isDark, isSi);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildCameraView(bool isDark, bool isSi) {
    if (_isCameraReady && _cameraController != null) {
      return Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: CameraPreview(_cameraController!),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 28),
                  onPressed: () => context.pop(),
                ),
                GestureDetector(
                  onTap: _takePicture,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.campusOrange, width: 4),
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.campusOrange,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48), // balance row
              ],
            ),
          ),
        ],
      );
    }

    // Fallback if camera hardware is not available (e.g. standard Android emulator or permission denied)
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _cameraPermissionDenied ? Icons.no_photography_rounded : Icons.camera_alt_outlined,
              size: 64,
              color: AppColors.campusOrange,
            ),
            const SizedBox(height: 16),
            Text(
              _cameraPermissionDenied
                  ? (isSi ? 'කැමරා අවසරය ප්‍රතික්ෂේප කර ඇත' : 'Camera permission required')
                  : (isSi ? 'භෞතික කැමරාවක් හමු නොවීය' : 'Camera preview unavailable'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              isSi
                  ? 'දේශන පුවරු සටහන් ගැනීමට හෝ පරික්ෂා කිරීම සඳහා පරීක්ෂණ ඡායාරූපයක් සාදන්න.'
                  : 'You can test the capture flow by taking a sample snapshot.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_rounded),
              label: Text(isSi ? 'පරීක්ෂණ සටහනක් ගන්න' : 'Take sample snapshot'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.campusOrange,
                foregroundColor: AppColors.deepNavy,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _simulateCapture,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    try {
      final file = await _cameraController!.takePicture();
      setState(() {
        _capturedFile = file;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _simulateCapture() async {
    final tempDir = await getTemporaryDirectory();
    final file = File(p.join(tempDir.path, 'sample_board_${DateTime.now().millisecondsSinceEpoch}.jpg'));
    // Generate 1-pixel or small valid test file if it doesn't exist
    await file.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01, 0x01, 0x01, 0x00, 0x48, 0x00, 0x48, 0x00, 0x00, 0xFF, 0xDB, 0x00, 0x43, 0x00, 0xFF, 0xD9]);
    setState(() {
      _capturedFile = XFile(file.path);
    });
  }

  Widget _buildPreviewAndSaveForm(List<dynamic> modules, bool isDark, bool isSi) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Captured Image Preview
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 220,
              width: double.infinity,
              color: isDark ? AppColors.cardDarkElevated : Colors.black12,
              child: Image.file(
                File(_capturedFile!.path),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, size: 48)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(isSi ? 'නැවත ගන්න' : 'Retake photo'),
              onPressed: () => setState(() => _capturedFile = null),
            ),
          ),
          const SizedBox(height: 8),

          // Tag Module
          DropdownButtonFormField<String>(
            value: _selectedModuleId,
            decoration: InputDecoration(
              labelText: isSi ? 'විෂයය තෝරන්න *' : 'Tag module *',
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

          // Date Picker
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (picked != null) setState(() => _selectedDate = picked);
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: isSi ? 'දේශන දිනය' : 'Lecture date',
                suffixIcon: const Icon(Icons.calendar_today_rounded, size: 20),
              ),
              child: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
            ),
          ),
          const SizedBox(height: 16),

          // Note
          TextField(
            controller: _noteController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: isSi ? 'සටහන (විකල්ප)' : 'Topic or note (optional)',
              hintText: isSi ? 'උදා: Subnetting formula slide' : 'e.g. Subnetting formula slide',
            ),
          ),
          const SizedBox(height: 32),

          // Save Button
          PrimaryButton(
            label: isSi ? 'ඡායාරූපය සුරකින්න' : 'Save to Board Snap',
            icon: Icons.save_rounded,
            onPressed: _savePhoto,
          ),
        ],
      ),
    );
  }

  Future<void> _savePhoto() async {
    if (_capturedFile == null || _selectedModuleId == null) return;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final boardsDir = Directory(p.join(appDir.path, 'board_photos'));
      if (!boardsDir.existsSync()) {
        await boardsDir.create(recursive: true);
      }

      final ext = p.extension(_capturedFile!.path).isEmpty ? '.jpg' : p.extension(_capturedFile!.path);
      final filename = 'board_${DateTime.now().millisecondsSinceEpoch}$ext';
      final savedPath = p.join(boardsDir.path, filename);

      await File(_capturedFile!.path).copy(savedPath);

      final photo = BoardPhoto(
        id: const Uuid().v4(),
        moduleId: _selectedModuleId!,
        filePath: savedPath,
        capturedDate: _selectedDate,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );

      await ref.read(boardPhotosProvider.notifier).addPhoto(photo);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Board photo saved!')),
        );
        context.pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save photo: $e')));
    }
  }
}
