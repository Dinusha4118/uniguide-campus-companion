import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/brand_logo_widget.dart';
import '../../widgets/primary_button.dart';

class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  ConsumerState<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSi = settings.language == 'si';

    final slides = [
      _OnboardingData(
        title: isSi ? 'ඔබේ වාරය එක බැල්මකින්' : 'Your semester at a glance',
        description: isSi
            ? 'විෂයයන්, පැමිණීම්, කාල සටහන සහ නියමිත දින සියල්ල ඔබගේ දුරකථනයේම සුරක්ෂිතව තබාගන්න.'
            : 'Enter your modules once. The app tracks your classes, attendance, deadlines, and GPA completely offline.',
        icon: Icons.calendar_month_rounded,
        previewBadge: isSi ? 'කාල සටහන' : 'TIMETABLE & CLASSES',
        previewTitle: isSi ? 'ක්‍රමලේඛනය' : 'Programming',
        previewSub: isSi ? '10:30–12:30 · ශාලාව 301' : '10:30–12:30 · Hall 301',
      ),
      _OnboardingData(
        title: isSi ? 'පැමිණීමේ ගැටලු මඟහරවා ගන්න' : 'No more attendance surprises',
        description: isSi
            ? 'සෑම දේශනයකටම පසු පැමිණියා හෝ නොපැමිණියා සලකුණු කර තවත් කීයකට නොපැමිණිය හැකිදැයි ක්ෂණිකව දැනගන්න.'
            : 'Know exactly how many lectures you can still miss while safely staying above your 80% requirement.',
        icon: Icons.verified_user_rounded,
        previewBadge: isSi ? 'ආරක්ෂිතයි' : 'SAFE SKIP METER',
        previewTitle: isSi ? 'තවත් 2 කට නොපැමිණිය හැක' : 'You can miss 2 more',
        previewSub: isSi ? 'පැමිණීම 85% · දේශන 12 න් 10 ක්' : '85% attendance · 10 of 12 lectures',
      ),
      _OnboardingData(
        title: isSi ? 'ඉලක්කගත GPA අගයට ළඟා වන්න' : 'Reach your target GPA',
        description: isSi
            ? 'විභාගවලට පසුව නොව, පෙර සිටම ඉලක්ක කළ යුතු ශ්‍රේණි මොනවාදැයි දැනගෙන සැලසුම් කරන්න.'
            : 'Calculate required grade points for remaining credits and explore what-if grade scenarios in real time.',
        icon: Icons.school_rounded,
        previewBadge: isSi ? 'GPA සැලසුම්කරු' : 'GPA TARGET PLANNER',
        previewTitle: isSi ? 'සාමාන්‍යය 3.60 ක් අවශ්‍යයි' : 'Aim for a 3.60 average',
        previewSub: isSi ? 'ඉදිරි ණය ඒකක 30 තුළ ඉලක්කය 3.30' : 'Across 30 remaining credits for 3.30 GPA',
      ),
      _OnboardingData(
        title: isSi ? 'ආරම්භ කිරීමට පෙර' : 'Before you start',
        description: isSi
            ? 'UniGuide යනු සිසුන් විසින් සාදන ලද නිල නොවන මෙවලමකි. ඔබගේ සියලු දත්ත දුරකථනයේ පමණක් සුරැකේ.'
            : 'UniGuide is an unofficial student companion. No account, no server, and no cloud synchronization. Your data stays on your phone.',
        icon: Icons.shield_outlined,
        previewBadge: isSi ? 'නිල නොවන සිසු මෙවලමකි' : 'UNOFFICIAL STUDENT TOOL',
        previewTitle: isSi ? '100% පුද්ගලික සහ නොබැඳි' : '100% Private & Offline',
        previewSub: isSi ? 'නිල විශ්වවිද්‍යාල මූලාශ්‍ර වලින් සැමවිටම තහවුරු කරගන්න.' : 'Always confirm official academic rules with university sources.',
        isFinalSlide: true,
      ),
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.night : AppColors.softCloud,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Skip button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const BrandLogoWidget(size: 38, showShadow: false),
                  if (_currentPage < slides.length - 1)
                    TextButton(
                      onPressed: () {
                        _pageController.animateToPage(
                          slides.length - 1,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Text(
                        isSi ? 'මඟහරින්න' : 'Skip',
                        style: TextStyle(
                          fontFamily: AppTypography.poppinsFont,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.campusOrange : AppColors.deepNavy,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 48),
                ],
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: slides.length,
                onPageChanged: (idx) {
                  setState(() => _currentPage = idx);
                },
                itemBuilder: (context, idx) {
                  final s = slides[idx];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Visual preview card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.campusOrange.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  s.previewBadge,
                                  style: AppTypography.overlineBadge(color: AppColors.campusOrange),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                s.previewTitle,
                                style: TextStyle(
                                  fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.poppinsFont,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                s.previewSub,
                                style: TextStyle(
                                  fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.interFont,
                                  fontSize: 14,
                                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Title & Description
                        Text(
                          s.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.poppinsFont,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          s.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.interFont,
                            fontSize: 15,
                            height: isSi ? 1.55 : 1.4,
                            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                          ),
                        ),

                        // Language selector on final slide
                        if (s.isFinalSlide) ...[
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _LanguageChip(
                                label: 'English',
                                isSelected: settings.language == 'en',
                                onSelect: () => ref.read(settingsProvider.notifier).setLanguage('en'),
                              ),
                              const SizedBox(width: 12),
                              _LanguageChip(
                                label: 'සිංහල',
                                isSelected: settings.language == 'si',
                                onSelect: () => ref.read(settingsProvider.notifier).setLanguage('si'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Indicators & Action Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                children: [
                  // Dot indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(slides.length, (idx) {
                      final isActive = idx == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.campusOrange
                              : (isDark ? AppColors.borderDark : const Color(0xFFCBD5E1)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Button
                  PrimaryButton(
                    label: _currentPage == slides.length - 1
                        ? (isSi ? 'මගේ වාරය සකසන්න' : 'Set up my semester')
                        : (isSi ? 'ඊළඟ පියවර' : 'Continue'),
                    onPressed: () {
                      if (_currentPage < slides.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        context.go('/setup-wizard');
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final String previewBadge;
  final String previewTitle;
  final String previewSub;
  final bool isFinalSlide;

  _OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.previewBadge,
    required this.previewTitle,
    required this.previewSub,
    this.isFinalSlide = false,
  });
}

class _LanguageChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelect;

  const _LanguageChip({
    required this.label,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontFamily: AppTypography.poppinsFont,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected
              ? AppColors.deepNavy
              : (isDark ? AppColors.textDarkHigh : AppColors.ink),
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.campusOrange,
      backgroundColor: isDark ? AppColors.cardDarkElevated : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.campusOrange : (isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
      ),
      onSelected: (_) => onSelect(),
    );
  }
}
