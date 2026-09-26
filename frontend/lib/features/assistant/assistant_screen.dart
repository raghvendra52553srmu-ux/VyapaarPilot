import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routing/app_router.dart';
import '../../services/api/api_service.dart';
import '../../shared/widgets/app_scaffold.dart';
import 'models/chat_message.dart';
import 'widgets/audio_wave_indicator.dart';
import 'widgets/chat_bubble.dart';

/// Reusable AI Assistant Screen and Panel.
/// Provides voice & text conversational interaction with agentic state flow
/// (listening, thinking, tool execution, confirmation, speaking).
class AssistantScreen extends StatefulWidget {
  final ApiService? apiService;

  const AssistantScreen({super.key, this.apiService});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  late final ApiService _apiService;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  AssistantState _currentState = AssistantState.idle;
  String _selectedLanguage = 'Hinglish';
  Timer? _stateTimer;

  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? MockApiService();

    // Initial greeting message from VyapaarPilot
    _messages.add(
      ChatMessage(
        id: 'msg_welcome',
        text:
            'Namaste Sharma ji! Main VyapaarPilot hoon. Aapke store ke sales, trends ya Tuesday drop ke baare mein kuch bhi poochein.',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _stateTimer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  void _handleLanguageChanged(String lang) {
    setState(() {
      _selectedLanguage = lang;
      String greeting = '';
      if (lang == 'हिंदी') {
        greeting =
            'नमस्ते शर्मा जी! मैं व्यापारपायलट हूँ। आपकी मंगलवार की बिक्री में 24% की कमी दर्ज हुई है। क्या आप 3 घंटे का प्रोमो चलाना चाहते हैं?';
      } else if (lang == 'English') {
        greeting =
            'Hello Mr. Sharma! I am VyapaarPilot. Your store transactions show a 24% dip every Tuesday between 4 PM and 7 PM. How can I help?';
      } else {
        greeting =
            'Namaste Sharma ji! Main VyapaarPilot hoon. Aapke store ke sales, trends ya Tuesday drop ke baare mein kuch bhi poochein.';
      }
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: greeting,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
    _scrollToBottom();
  }

  void _submitMessage(String query) async {
    final text = query.trim();
    if (text.isEmpty) return;

    _textController.clear();

    // 1. Add User Message
    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _currentState = AssistantState.thinking;
    });
    _scrollToBottom();

    final isExperimentQuery = text.toLowerCase().contains('experiment') ||
        text.toLowerCase().contains('promo') ||
        text.toLowerCase().contains('start');

    // 2. Simulate Backend / AI processing & Tool Execution
    if (isExperimentQuery) {
      // Step A: Tool execution state
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;

      setState(() {
        _currentState = AssistantState.toolExecution;
        _messages.add(
          ChatMessage(
            id: 'tool_${DateTime.now().millisecondsSinceEpoch}',
            text:
                'Checking parameters for Tuesday 4 PM – 7 PM promotion experiment...',
            isUser: false,
            timestamp: DateTime.now(),
            toolName: 'validate_experiment_params(window="16:00-19:00", discount=10%)',
          ),
        );
      });
      _scrollToBottom();

      // Step B: Agentic Confirmation Proposal
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;

      setState(() {
        _currentState = AssistantState.confirmation;
        _messages.add(
          ChatMessage(
            id: 'proposal_${DateTime.now().millisecondsSinceEpoch}',
            text:
                'I have prepared the experiment configuration based on your historical Tuesday data.',
            isUser: false,
            timestamp: DateTime.now(),
            actionProposal: ActionProposal(
              title: 'Start Tuesday 4–7 PM experiment?',
              description:
                  '10% promotion on Tuesday 4 PM – 7 PM to recover 24% revenue drop.',
              actionType: 'start_experiment',
            ),
          ),
        );
      });
      _scrollToBottom();
      return;
    }

    // 3. Regular Merchant Q&A via ApiService
    try {
      final aiResp = await _apiService.askAi(
        'M001',
        text,
        language: _selectedLanguage,
      );

      if (!mounted) return;

      setState(() {
        _currentState = AssistantState.speaking;
        _messages.add(
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: aiResp.answer,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
      _scrollToBottom();

      // Reset speaking state after a brief period
      _stateTimer?.cancel();
      _stateTimer = Timer(const Duration(seconds: 4), () {
        if (mounted && _currentState == AssistantState.speaking) {
          setState(() {
            _currentState = AssistantState.idle;
          });
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _currentState = AssistantState.idle;
        _messages.add(
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text:
                'Aapke store data ke anusaar Tuesday 4 PM se 7 PM ke beech sales 24% kam chal rahi hai (₹13,800 baseline ke mukable ₹10,488).',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
      _scrollToBottom();
    }
  }

  void _toggleMic() {
    if (_currentState == AssistantState.listening) {
      // Finish listening and transcribe
      setState(() {
        _currentState = AssistantState.idle;
      });
      _submitMessage('Tuesday sales drop ka kya reason hai?');
    } else {
      // Start listening state
      setState(() {
        _currentState = AssistantState.listening;
      });

      // Automatically simulate transcribed voice query after 2 seconds if not stopped
      _stateTimer?.cancel();
      _stateTimer = Timer(const Duration(seconds: 2), () {
        if (mounted && _currentState == AssistantState.listening) {
          setState(() {
            _currentState = AssistantState.idle;
          });
          _submitMessage('Tuesday sales kyun kam ho rahe hain?');
        }
      });
    }
  }

  void _onConfirmAction(ActionProposal proposal) {
    setState(() {
      proposal.isConfirmed = true;
      _currentState = AssistantState.idle;
    });

    // Navigate to Experiment Screen
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        Navigator.pushNamed(context, AppRouter.experiment);
      }
    });
  }

  void _onCancelAction(ActionProposal proposal) {
    setState(() {
      proposal.isCancelled = true;
      _currentState = AssistantState.idle;
    });
  }

  void _stopSpeaking() {
    _stateTimer?.cancel();
    setState(() {
      _currentState = AssistantState.idle;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'VyapaarPilot Assistant',
      currentIndex: 3,
      showAssistantFab: false,
      body: Column(
        children: [
          // Language selector bar
          _buildLanguageBar(),

          // Active status indicator banners (Listening, Thinking, Speaking)
          _buildStateBanner(),

          // Conversation history list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: AppSpacing.screenPadding,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(
                  message: message,
                  onConfirmAction: message.actionProposal != null
                      ? () => _onConfirmAction(message.actionProposal!)
                      : null,
                  onCancelAction: message.actionProposal != null
                      ? () => _onCancelAction(message.actionProposal!)
                      : null,
                );
              },
            ),
          ),

          // Suggested quick queries
          _buildSuggestedChips(),

          // Input control dock (Text, Mic, Send)
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildLanguageBar() {
    final languages = ['Hinglish', 'हिंदी', 'English'];
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.translate,
            size: 16.0,
            color: AppColors.secondaryBlue,
          ),
          const SizedBox(width: AppSpacing.xs),
          const Text(
            'Language:',
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Wrap(
            spacing: 6.0,
            children: languages.map((lang) {
              final isSelected = _selectedLanguage == lang;
              return ChoiceChip(
                label: Text(
                  lang,
                  style: TextStyle(
                    fontSize: 11.0,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                selected: isSelected,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.background,
                onSelected: (_) => _handleLanguageChanged(lang),
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStateBanner() {
    if (_currentState == AssistantState.listening) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        color: AppColors.lightBlue,
        child: Row(
          children: [
            const AudioWaveIndicator(color: AppColors.secondaryBlue),
            const SizedBox(width: AppSpacing.md),
            const Expanded(
              child: Text(
                'Listening in Hindi / English... Tap mic to finish',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.stop, color: AppColors.primary, size: 20),
              onPressed: _toggleMic,
            ),
          ],
        ),
      );
    } else if (_currentState == AssistantState.thinking) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        color: AppColors.lightBlue.withValues(alpha: 0.5),
        child: const Row(
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2.0),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'VyapaarPilot is analyzing store data...',
                style: TextStyle(
                  fontSize: 12.0,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (_currentState == AssistantState.speaking) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        color: AppColors.successLight,
        child: Row(
          children: [
            const Icon(
              Icons.volume_up,
              size: 18.0,
              color: AppColors.success,
            ),
            const SizedBox(width: AppSpacing.sm),
            const Expanded(
              child: Text(
                'VyapaarPilot is speaking...',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            ),
            TextButton(
              onPressed: _stopSpeaking,
              child: const Text(
                'Stop',
                style: TextStyle(
                  fontSize: 12.0,
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSuggestedChips() {
    final chips = [
      'Tuesday sales kyun kam ho rahe hain?',
      'Start Tuesday 4-7 PM experiment',
      "Today's sales summary",
    ];

    return Container(
      height: 38.0,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final chip = chips[index];
          return ActionChip(
            label: Text(
              chip,
              style: const TextStyle(
                fontSize: 12.0,
                color: AppColors.primary,
              ),
            ),
            backgroundColor: AppColors.surface,
            side: const BorderSide(color: AppColors.border),
            onPressed: () => _submitMessage(chip),
          );
        },
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          // Voice Mic Button
          IconButton(
            key: const Key('assistant_mic_button'),
            icon: Icon(
              _currentState == AssistantState.listening
                  ? Icons.mic
                  : Icons.mic_none,
              color: _currentState == AssistantState.listening
                  ? Colors.red
                  : AppColors.primary,
              size: 24.0,
            ),
            onPressed: _toggleMic,
          ),
          const SizedBox(width: AppSpacing.xs),

          // Text Field
          Expanded(
            child: TextField(
              key: const Key('assistant_text_input'),
              controller: _textController,
              decoration: InputDecoration(
                hintText: _selectedLanguage == 'हिंदी'
                    ? 'सवाल पूछें (उदा. मंगलवार की बिक्री क्यों कम है?)'
                    : 'Ask anything (e.g. Tuesday sales kyun kam hain?)',
                hintStyle: const TextStyle(fontSize: 13.0),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 10.0,
                ),
                border: const OutlineInputBorder(
                  borderRadius: AppRadius.roundedLarge,
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: AppRadius.roundedLarge,
                  borderSide: BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
                filled: true,
                fillColor: AppColors.background,
              ),
              onSubmitted: _submitMessage,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),

          // Send Button
          IconButton(
            key: const Key('assistant_send_button'),
            icon: const Icon(
              Icons.send,
              color: AppColors.primary,
              size: 22.0,
            ),
            onPressed: () => _submitMessage(_textController.text),
          ),
        ],
      ),
    );
  }
}
