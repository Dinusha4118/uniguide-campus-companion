import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/app_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../../domain/calculations/ai_study_companion_engine.dart';
import '../../domain/calculations/gpa_calculator.dart';

class AiAssistantModal extends ConsumerStatefulWidget {
  const AiAssistantModal({super.key});

  @override
  ConsumerState<AiAssistantModal> createState() => _AiAssistantModalState();
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  _ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class _AiAssistantModalState extends ConsumerState<AiAssistantModal> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;

  final List<String> _quickPromptsEn = [
    'How do I boost my GPA to my target?',
    'What is my most urgent deadline?',
    'What should I study today?',
    'How does attendance safe skip work?',
  ];

  final List<String> _quickPromptsSi = [
    'මගේ ඉලක්ක GPA එකට ළඟාවන්නේ කෙසේද?',
    'මීළඟට ඇති හදිසි පැවරුම කුමක්ද?',
    'අද දින පාඩම් කළ යුතු විෂයය කුමක්ද?',
    'පැමිණීමේ අවම සීමාව රැකගන්නේ කෙසේද?',
  ];

  @override
  void initState() {
    super.initState();
    // Initial welcome message
    _messages.add(
      _ChatMessage(
        text: '👋 Hi! I am your UniGuide AI Academic Mentor. Ask me anything about your modules, GPA targets, deadlines, or exam strategies!',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String query) async {
    if (query.trim().isEmpty) return;

    final userQuery = query.trim();
    _textController.clear();

    setState(() {
      _messages.add(_ChatMessage(text: userQuery, isUser: true, timestamp: DateTime.now()));
      _isTyping = true;
    });

    _scrollToBottom();

    // Query data
    final settings = ref.read(settingsProvider);
    final modules = ref.read(modulesProvider).value ?? [];
    final deadlines = ref.read(deadlinesProvider).value ?? [];
    final isSi = settings.language == 'si';

    final gpaResult = GpaCalculator.calculateCurrentGpa(
      modules,
      settings.academicSettings.gradeScale,
    );

    // Simulate smart AI response latency for natural feeling
    await Future.delayed(const Duration(milliseconds: 600));

    final aiReply = AiStudyCompanionEngine.askAcademicAssistant(
      query: userQuery,
      modules: modules,
      deadlines: deadlines,
      currentGpa: gpaResult.currentGpa,
      targetGpa: settings.academicSettings.targetGpa,
      isSinhala: isSi,
    );

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add(_ChatMessage(text: aiReply, isUser: false, timestamp: DateTime.now()));
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = ref.watch(settingsProvider);
    final isSi = settings.language == 'si';
    final quickPrompts = isSi ? _quickPromptsSi : _quickPromptsEn;

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: isDark ? AppColors.night : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle & Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
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
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF6366F1).withOpacity(0.18),
                          ),
                          child: const Icon(
                            Icons.psychology_rounded,
                            color: Color(0xFF6366F1),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isSi ? 'AI අධ්‍යයන උපදේශක' : 'AI Academic Mentor',
                              style: TextStyle(
                                fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.poppinsFont,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: isDark ? Colors.white : AppColors.deepNavy,
                              ),
                            ),
                            Text(
                              isSi ? 'නොබැඳි ආරක්ෂිත AI මඟපෙන්වීම' : '100% Offline Academic Intelligence',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, idx) {
                final msg = _messages[idx];
                final isUser = msg.isUser;

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFF6366F1)
                          : (isDark ? AppColors.cardDarkElevated : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                        bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        fontFamily: AppTypography.interFont,
                        fontSize: 13.5,
                        color: isUser
                            ? Colors.white
                            : (isDark ? AppColors.textDarkHigh : AppColors.ink),
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6366F1)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isSi ? 'සිතමින් සිටී...' : 'Thinking...',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                    ),
                  ),
                ],
              ),
            ),

          // Quick Prompt Suggestion Chips
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: quickPrompts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                return ActionChip(
                  label: Text(
                    quickPrompts[idx],
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                  backgroundColor: isDark ? AppColors.cardDarkElevated : const Color(0xFFEEF2FF),
                  side: BorderSide(color: const Color(0xFF6366F1).withOpacity(0.3)),
                  onPressed: () => _sendMessage(quickPrompts[idx]),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Input Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    onSubmitted: _sendMessage,
                    decoration: InputDecoration(
                      hintText: isSi ? 'ප්‍රශ්නයක් අසන්න...' : 'Ask your academic AI assistant...',
                      hintStyle: const TextStyle(fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                      filled: true,
                      fillColor: isDark ? AppColors.night : const Color(0xFFF8FAFC),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: Color(0xFF6366F1)),
                  onPressed: () => _sendMessage(_textController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
