import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../application/providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/brand_logo_widget.dart';
import '../../widgets/primary_button.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _audioPlayed = false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // Spring/bounce pop-in scale
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 65,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 35,
      ),
    ]).animate(_animController);

    // Gentle compass needle tilt on entry
    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.12, end: 0.06)
            .chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.06, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(_animController);

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    // Gentle continuous breathing glow
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.65, 1.0, curve: Curves.easeInOut),
      ),
    );

    _playIntro();
  }

  Future<void> _playIntro() async {
    _animController.forward();
    // Play voice after brief start
    await Future.delayed(const Duration(milliseconds: 250));
    if (mounted && !_audioPlayed) {
      _audioPlayed = true;
      try {
        await _audioPlayer.play(AssetSource('audio/uniguide_intro.wav'));
      } catch (e) {
        debugPrint('Audio playback error: $e');
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.night : AppColors.softCloud,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Animated Logo with Compass Flourish & Pulse
              AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Transform.scale(
                      scale: _scaleAnimation.value * _pulseAnimation.value,
                      child: Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: child,
                      ),
                    ),
                  );
                },
                child: Hero(
                  tag: 'app_logo',
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0056D2).withOpacity(0.25),
                          blurRadius: 36,
                          spreadRadius: 4,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const BrandLogoWidget(size: 130.0),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // App Name & Tagline
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Uni',
                          style: TextStyle(
                            fontFamily: AppTypography.poppinsFont,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: isDark ? Colors.white : const Color(0xFF0D253F),
                          ),
                        ),
                        Text(
                          'Guide',
                          style: TextStyle(
                            fontFamily: AppTypography.poppinsFont,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: const Color(0xFF0070F3),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Golden compass pointer icon accent matching logo
                        Transform.rotate(
                          angle: 0.35,
                          child: const Icon(
                            Icons.navigation_rounded,
                            size: 24,
                            color: Color(0xFFFDB913),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      settings.language == 'si'
                          ? 'ඔබ සිටින තැන දැනගන්න. ඊළඟ පියවර සැලසුම් කරන්න.'
                          : 'Know where you stand. Plan what’s next.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: settings.language == 'si'
                            ? AppTypography.sinhalaFont
                            : AppTypography.interFont,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                        height: settings.language == 'si' ? 1.55 : 1.4,
                        color: isDark ? AppColors.textDarkMuted : const Color(0xFF4A5568),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: settings.language == 'si' ? 'ආරම්භ කරමු' : "Let's begin",
                onPressed: () {
                  if (settings.onboardingCompleted) {
                    context.go('/home');
                  } else {
                    context.go('/onboarding');
                  }
                },
              ),
              const SizedBox(height: 14),
              Text(
                'Unofficial student tool. Always confirm with official university sources.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.interFont,
                  fontSize: 11,
                  color: isDark ? AppColors.textDarkMuted.withOpacity(0.7) : AppColors.textLightMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
