import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../../domain/calculations/ai_study_companion_engine.dart';

class AiFlashcardsModal extends StatefulWidget {
  final String moduleCode;
  final String? note;
  final bool isSi;

  const AiFlashcardsModal({
    super.key,
    required this.moduleCode,
    required this.note,
    required this.isSi,
  });

  @override
  State<AiFlashcardsModal> createState() => _AiFlashcardsModalState();
}

class _AiFlashcardsModalState extends State<AiFlashcardsModal> {
  int _currentIndex = 0;
  bool _showAnswer = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final flashcards = AiStudyCompanionEngine.generateFlashcardsFromBoardNote(
      moduleCode: widget.moduleCode,
      note: widget.note,
      isSinhala: widget.isSi,
    );

    final currentCard = flashcards.isNotEmpty ? flashcards[_currentIndex] : null;

    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.night : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
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
                      Icons.style_rounded,
                      color: Color(0xFF6366F1),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.isSi ? 'AI අධ්‍යයන ෆ්ලෑෂ්කාඩ්' : 'AI Smart Flashcards',
                    style: TextStyle(
                      fontFamily: widget.isSi ? AppTypography.sinhalaFont : AppTypography.poppinsFont,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: isDark ? Colors.white : AppColors.deepNavy,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (currentCard == null)
            const Expanded(child: Center(child: Text('No notes available.')))
          else ...[
            // Progress indicator
            Text(
              'Card ${_currentIndex + 1} of ${flashcards.length} · ${currentCard.category}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
              ),
            ),
            const SizedBox(height: 16),

            // Flip Card Area
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showAnswer = !_showAnswer;
                  });
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Container(
                    key: ValueKey<bool>(_showAnswer),
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _showAnswer
                            ? [
                                const Color(0xFF10B981).withOpacity(0.15),
                                const Color(0xFF047857).withOpacity(0.08),
                              ]
                            : [
                                const Color(0xFF6366F1).withOpacity(0.15),
                                const Color(0xFF4338CA).withOpacity(0.08),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _showAnswer
                            ? AppColors.mintSuccess.withOpacity(0.5)
                            : const Color(0xFF6366F1).withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _showAnswer ? Icons.check_circle_outline_rounded : Icons.help_outline_rounded,
                          size: 36,
                          color: _showAnswer ? AppColors.mintSuccess : const Color(0xFF6366F1),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _showAnswer
                              ? (widget.isSi ? 'පිළිතුර / සාරාංශය' : 'REVISION ANSWER')
                              : (widget.isSi ? 'ප්‍රශ්නය / මූලික සංකල්පය' : 'QUESTION / CONCEPT'),
                          style: TextStyle(
                            fontFamily: AppTypography.poppinsFont,
                            fontSize: 11,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w800,
                            color: _showAnswer ? AppColors.mintSuccess : const Color(0xFF6366F1),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _showAnswer ? currentCard.answer : currentCard.question,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: widget.isSi ? AppTypography.sinhalaFont : AppTypography.poppinsFont,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppColors.deepNavy,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          widget.isSi ? 'පෙරළීමට තට්ටු කරන්න' : 'Tap card to flip',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Navigation Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: _currentIndex > 0
                      ? () {
                          setState(() {
                            _currentIndex--;
                            _showAnswer = false;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.arrow_back_rounded, size: 16),
                  label: Text(widget.isSi ? 'පෙර' : 'Previous'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _currentIndex < flashcards.length - 1
                      ? () {
                          setState(() {
                            _currentIndex++;
                            _showAnswer = false;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: Text(widget.isSi ? 'ඊළඟ' : 'Next Card'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
