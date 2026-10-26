import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../../application/providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../../domain/calculations/ai_vision_solver_engine.dart';
import '../../../data/services/ai_voice_service.dart';

class AiCameraQuestionSolverScreen extends ConsumerStatefulWidget {
  const AiCameraQuestionSolverScreen({super.key});

  @override
  ConsumerState<AiCameraQuestionSolverScreen> createState() => _AiCameraQuestionSolverScreenState();
}

class _AiCameraQuestionSolverScreenState extends ConsumerState<AiCameraQuestionSolverScreen>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraReady = false;
  bool _isAnalyzing = false;
  XFile? _capturedImage;

  // Animation controllers
  late AnimationController _scanLaserController;
  late Animation<double> _scanLaserAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Result state
  AiVisionQuestionResult? _solutionResult;
  bool _isVoiceSpeaking = false;
  bool _speechInSinhala = false;
  String _selectedSubjectHint = 'Mathematics';

  final List<String> _subjects = [
    'Mathematics',
    'Computer Science',
    'Physics',
    'General Knowledge',
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initializeCamera();
    AiVoiceService().initialize();

    // Default voice language according to user's saved preference
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isSi = ref.read(settingsProvider).language == 'si';
      if (mounted) {
        setState(() {
          _speechInSinhala = isSi;
        });
      }
    });
  }

  void _initAnimations() {
    _scanLaserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _scanLaserAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(parent: _scanLaserController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
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
        if (mounted) setState(() => _isCameraReady = true);
      }
    } catch (e) {
      debugPrint('Camera initialization notice: $e');
      if (mounted) setState(() => _isCameraReady = false);
    }
  }

  @override
  void dispose() {
    AiVoiceService().stop();
    _scanLaserController.dispose();
    _pulseController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _captureAndSolve({String? customQuery}) async {
    if (_isAnalyzing) return;

    setState(() {
      _isAnalyzing = true;
    });

    String recognizedRawText = customQuery ?? '';

    if (recognizedRawText.isEmpty) {
      try {
        if (_cameraController != null && _cameraController!.value.isInitialized) {
          _capturedImage = await _cameraController!.takePicture();
          
          // Real OCR Text Recognition via Google ML Kit
          try {
            final inputImage = InputImage.fromFilePath(_capturedImage!.path);
            final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
            final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
            await textRecognizer.close();

            recognizedRawText = recognizedText.text.trim();
            debugPrint('MLKit OCR Recognized: "$recognizedRawText"');
          } catch (ocrErr) {
            debugPrint('MLKit OCR runtime notice: $ocrErr');
          }
        }
      } catch (e) {
        debugPrint('Capture image fallback: $e');
      }
    }

    if (recognizedRawText.isEmpty) {
      // Small delay for UI smoothness
      await Future.delayed(const Duration(milliseconds: 600));
    }

    final result = AiVisionSolverEngine.analyzeQuestion(
      rawInputText: recognizedRawText,
      subjectHint: _selectedSubjectHint,
    );

    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _solutionResult = result;
      });

      // Auto-narrate in selected voice
      _playVoiceNarration();
    }
  }

  void _showManualQuestionModal(BuildContext context) {
    final textController = TextEditingController();
    final isSi = ref.read(settingsProvider).language == 'si';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF0F172A)
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isSi ? 'ප්‍රශ්නය ලියන්න හෝ සංස්කරණය කරන්න' : 'Type or Edit Question',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                isSi
                    ? 'කැමරාවෙන් පැහැදිලි නැතිනම් ඕනෑම ගණිත, විද්‍යා හෝ පරිගණක ප්‍රශ්නයක් මෙහි ලියන්න (උදා: 45 * 12, 100 / 4, dy/dx):'
                    : 'Enter any math equation, algorithm, or physics question (e.g. 45 * 12, 100 / 4, dy/dx of 3x^2):',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textController,
                maxLines: 3,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'e.g. 25 * 16, derivative of x^2 + 5x, or binary search',
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final query = textController.text.trim();
                    Navigator.pop(ctx);
                    if (query.isNotEmpty) {
                      _captureAndSolve(customQuery: query);
                    }
                  },
                  icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
                  label: Text(
                    isSi ? 'AI විසඳුම සහ කටහඬ ලබාගන්න' : 'Solve & Voice Explain',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _playVoiceNarration() async {
    if (_solutionResult == null) return;

    setState(() => _isVoiceSpeaking = true);

    final textToSpeak = _speechInSinhala
        ? _solutionResult!.sinhalaVoiceScript
        : _solutionResult!.englishVoiceScript;

    await AiVoiceService().speak(
      text: textToSpeak,
      isSinhala: _speechInSinhala,
      onStart: () {
        if (mounted) setState(() => _isVoiceSpeaking = true);
      },
      onComplete: () {
        if (mounted) setState(() => _isVoiceSpeaking = false);
      },
    );
  }

  void _stopVoiceNarration() async {
    await AiVoiceService().stop();
    if (mounted) setState(() => _isVoiceSpeaking = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = ref.watch(settingsProvider);
    final isSi = settings.language == 'si';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.7),
        elevation: 0,
        title: Text(
          isSi ? 'AI ප්‍රශ්න විසඳනය සහ කටහඬ' : 'AI Question Camera & Voice',
          style: TextStyle(
            fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.poppinsFont,
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            AiVoiceService().stop();
            context.pop();
          },
        ),
        actions: [
          // Voice Language Toggle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF818CF8)),
            ),
            child: Row(
              children: [
                const Icon(Icons.record_voice_over_rounded, size: 16, color: Color(0xFF818CF8)),
                const SizedBox(width: 4),
                DropdownButtonHideUnderline(
                  child: DropdownButton<bool>(
                    value: _speechInSinhala,
                    dropdownColor: const Color(0xFF1E1B4B),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 18),
                    items: const [
                      DropdownMenuItem(
                        value: false,
                        child: Text('Female EN 🇬🇧', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                      DropdownMenuItem(
                        value: true,
                        child: Text('Female SI 🇱🇰', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _speechInSinhala = val);
                        if (_solutionResult != null && _isVoiceSpeaking) {
                          _playVoiceNarration();
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Camera Preview or Fallback
          Positioned.fill(
            child: _isCameraReady && _cameraController != null
                ? CameraPreview(_cameraController!)
                : Container(
                    color: const Color(0xFF0F172A),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined, size: 64, color: Colors.white.withOpacity(0.4)),
                          const SizedBox(height: 16),
                          Text(
                            isSi
                                ? 'කැමරා සංවේදකය සූදානම්... ප්‍රශ්නය ස්කෑන් කරන්න'
                                : 'AI Vision Ready · Point camera at any question',
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // 2. Futuristic Reticle Target Frame with Laser Scan
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final boxWidth = constraints.maxWidth * 0.86;
                final boxHeight = constraints.maxHeight * 0.46;

                return Center(
                  child: Container(
                    width: boxWidth,
                    height: boxHeight,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.6), width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        // Corner brackets
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Color(0xFF818CF8), width: 4),
                                left: BorderSide(color: Color(0xFF818CF8), width: 4),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Color(0xFF818CF8), width: 4),
                                right: BorderSide(color: Color(0xFF818CF8), width: 4),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0xFF818CF8), width: 4),
                                left: BorderSide(color: Color(0xFF818CF8), width: 4),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0xFF818CF8), width: 4),
                                right: BorderSide(color: Color(0xFF818CF8), width: 4),
                              ),
                            ),
                          ),
                        ),

                        // Animated Laser Scan Line
                        AnimatedBuilder(
                          animation: _scanLaserAnimation,
                          builder: (context, child) {
                            return Positioned(
                              top: boxHeight * _scanLaserAnimation.value,
                              left: 12,
                              right: 12,
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF38BDF8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF38BDF8).withOpacity(0.8),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        // Hint Label
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isSi
                                  ? 'ප්‍රශ්නය හෝ සටහන රාමුව තුළ තබන්න'
                                  : 'Align exam or tutorial question inside frame',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 3. Top Subject Selector Pills
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _subjects.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  final isSel = _selectedSubjectHint == _subjects[idx];
                  return ChoiceChip(
                    label: Text(
                      _subjects[idx],
                      style: TextStyle(
                        fontSize: 12,
                        color: isSel ? Colors.white : Colors.white70,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSel,
                    selectedColor: const Color(0xFF6366F1),
                    backgroundColor: Colors.black.withOpacity(0.6),
                    onSelected: (val) {
                      if (val) setState(() => _selectedSubjectHint = _subjects[idx]);
                    },
                  );
                },
              ),
            ),
          ),

          // 4. Capture & Scan Action Button (when no result yet or analyzing)
          if (_solutionResult == null)
            Positioned(
              bottom: 36,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  Row(
                    children: [
                      // Manual Type / Edit button
                      Container(
                        height: 64,
                        width: 64,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF818CF8).withOpacity(0.8), width: 1.5),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 28),
                          tooltip: isSi ? 'ප්‍රශ්නය ලියන්න' : 'Type Question',
                          onPressed: () => _showManualQuestionModal(context),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Scan button
                      Expanded(
                        child: ScaleTransition(
                          scale: _pulseAnimation,
                          child: GestureDetector(
                            onTap: () => _captureAndSolve(),
                            child: Container(
                              height: 68,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                ),
                                borderRadius: BorderRadius.circular(34),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6366F1).withOpacity(0.5),
                                    blurRadius: 24,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_isAnalyzing)
                                    const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                    )
                                  else
                                    const Icon(Icons.document_scanner_rounded, color: Colors.white, size: 26),
                                  const SizedBox(width: 10),
                                  Text(
                                    _isAnalyzing
                                        ? (isSi ? 'විසඳුම සකසමින්...' : 'AI Solving...')
                                        : (isSi ? 'ස්කෑන් කරන්න 🎙️' : 'Scan & Voice Solve 🎙️'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // 5. Intelligent Solution Drawer / Card with Voice Waveform
          if (_solutionResult != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.65,
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white24 : Colors.black12,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Header with voice indicator & Retake button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1).withOpacity(0.18),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF6366F1),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _solutionResult!.recognizedTopic,
                                    style: TextStyle(
                                      fontFamily: AppTypography.poppinsFont,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: isDark ? Colors.white : AppColors.deepNavy,
                                    ),
                                  ),
                                  Text(
                                    'AI Confidence: ${(_solutionResult!.confidenceScore * 100).toInt()}% · Female AI Voice',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.mintSuccess,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh_rounded),
                            tooltip: 'Scan another question',
                            onPressed: () {
                              AiVoiceService().stop();
                              setState(() {
                                _solutionResult = null;
                                _isVoiceSpeaking = false;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Voice Controls & Audio Player Bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF6366F1).withOpacity(0.18),
                              const Color(0xFF8B5CF6).withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF818CF8).withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                _isVoiceSpeaking ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                                color: const Color(0xFF6366F1),
                                size: 36,
                              ),
                              onPressed: _isVoiceSpeaking ? _stopVoiceNarration : _playVoiceNarration,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isVoiceSpeaking
                                        ? (_speechInSinhala ? 'සිංහල කටහඬින් පැහැදිලි කරයි 🔊' : 'Speaking in Female Voice 🔊')
                                        : (_speechInSinhala ? 'කටහඬින් සවන් දෙන්න 🎙️' : 'Tap to Listen Voice Solution 🎙️'),
                                    style: TextStyle(
                                      fontFamily: AppTypography.poppinsFont,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.5,
                                      color: isDark ? Colors.white : AppColors.deepNavy,
                                    ),
                                  ),
                                  Text(
                                    _speechInSinhala
                                        ? 'Natural Sinhala voice narration'
                                        : 'Clear English step-by-step narration',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _speechInSinhala,
                              activeColor: const Color(0xFF6366F1),
                              onChanged: (val) {
                                setState(() => _speechInSinhala = val);
                                _playVoiceNarration();
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Recognized Question text
                      Text(
                        isSi ? 'හඳුනාගත් ප්‍රශ්නය:' : 'Recognized Problem:',
                        style: TextStyle(
                          fontFamily: AppTypography.poppinsFont,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _solutionResult!.questionText,
                        style: TextStyle(
                          fontFamily: AppTypography.interFont,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isDark ? Colors.white : AppColors.deepNavy,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Step-by-Step Breakdown
                      Text(
                        isSi ? 'පියවරෙන් පියවර විසඳුම:' : 'Step-by-Step Breakdown:',
                        style: TextStyle(
                          fontFamily: AppTypography.poppinsFont,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      for (int i = 0; i < _solutionResult!.stepByStepBreakdown.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1).withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${i + 1}',
                                    style: const TextStyle(
                                      color: Color(0xFF6366F1),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _solutionResult!.stepByStepBreakdown[i],
                                  style: TextStyle(
                                    fontFamily: AppTypography.interFont,
                                    fontSize: 12.5,
                                    color: isDark ? AppColors.textDarkHigh : AppColors.ink,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),

                      // Complete Text Solution (English & Sinhala)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _speechInSinhala || isSi
                              ? _solutionResult!.sinhalaAnswer
                              : _solutionResult!.englishAnswer,
                          style: TextStyle(
                            fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.interFont,
                            fontSize: 13,
                            height: 1.45,
                            color: isDark ? Colors.white : AppColors.deepNavy,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Exam Tip
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.campusOrange.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.campusOrange.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lightbulb_outline_rounded, color: AppColors.campusOrange, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '💡 ${_solutionResult!.examTip}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.campusOrange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
