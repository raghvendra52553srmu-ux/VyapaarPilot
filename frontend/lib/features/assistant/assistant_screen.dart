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

/// Multimodal AI Assistant Screen and Panel for VyapaarPilot.
/// Provides voice & text conversational interaction with agentic state flow
/// (listening, transcribing, thinking, tool execution, confirmation, speaking, error).
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
  Timer? _autoListenTimer;
  Timer? _navigationTimer;

  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? HttpApiService();

    // Initial greeting message from VyapaarPilot
    _messages.add(
      ChatMessage(
        id: 'msg_welcome',
        text: 'Namaste Sharma ji! Main VyapaarPilot hoon. Aapke store ke sales, trends ya Tuesday drop ke baare mein kuch bhi poochein.',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _stateTimer?.cancel();
    _autoListenTimer?.cancel();
    _navigationTimer?.cancel();
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
        greeting = 'नमस्ते शर्मा जी! मैं व्यापारपायलट हूँ। आपकी मंगलवार की बिक्री में 24% की कमी दर्ज हुई है। क्या आप 3 घंटे का प्रोमो चलाना चाहते हैं?';
      } else if (lang == 'English') {
        greeting = 'Hello Mr. Sharma! I am VyapaarPilot. Your store transactions show a 24% dip every Tuesday between 4 PM and 7 PM. How can I help?';
      } else {
        greeting = 'Namaste Sharma ji! Main VyapaarPilot hoon. Aapke store ke sales, trends ya Tuesday drop ke baare mein kuch bhi poochein.';
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

    try {
      final aiResp = await _apiService.askAi(
        'M001',
        text,
        language: _selectedLanguage,
      );

      if (!mounted) return;

      final isActionRequired =
          aiResp.intent == 'ACTION_CONFIRMATION' ||
          aiResp.actions.any((a) => a.type == 'confirmation') ||
          text.toLowerCase().contains('experiment start') ||
          text.toLowerCase().contains('start experiment') ||
          (text.toLowerCase().contains('start') &&
              text.toLowerCase().contains('experiment')) ||
          text.toLowerCase().contains('start karo') ||
          text.toLowerCase().contains('chalao');

      if (isActionRequired) {
        // Step A: Tool execution / parameter validation
        setState(() {
          _currentState = AssistantState.toolCall;
          _messages.add(
            ChatMessage(
              id: 'tool_${DateTime.now().millisecondsSinceEpoch}',
              text: 'Checking parameters for Tuesday 4 PM – 7 PM promotion experiment...',
              isUser: false,
              timestamp: DateTime.now(),
              toolName: 'validate_experiment_params(window="16:00-19:00", discount=10%)',
            ),
          );
        });
        _scrollToBottom();

        // Step B: Merchant Confirmation State
        await Future.delayed(const Duration(milliseconds: 250));
        if (!mounted) return;

        final confirmationPrompt =
            aiResp.actions
                .where(
                  (a) => a.requiresConfirmation && a.confirmationPrompt != null,
                )
                .map((a) => a.confirmationPrompt!)
                .firstOrNull ??
            'Tuesday 4–7 PM experiment start karun?';

        setState(() {
          _currentState = AssistantState.confirmation;
          _messages.add(
            ChatMessage(
              id: 'proposal_${DateTime.now().millisecondsSinceEpoch}',
              text: confirmationPrompt,
              isUser: false,
              timestamp: DateTime.now(),
              actionProposal: ActionProposal(
                title: 'Start Tuesday 4–7 PM experiment?',
                description: '10% promotion on Tuesday 4 PM – 7 PM to recover 24% revenue drop.',
                actionType: 'create_experiment',
                actionId: aiResp.actions.isNotEmpty
                    ? aiResp.actions.first.id
                    : null,
              ),
            ),
          );
        });
        _scrollToBottom();
      } else {
        // Normal Agent response
        setState(() {
          _currentState = AssistantState.speaking;
          _messages.add(
            ChatMessage(
              id: aiResp.messageId.isNotEmpty
                  ? aiResp.messageId
                  : DateTime.now().millisecondsSinceEpoch.toString(),
              text: aiResp.answer,
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
        _scrollToBottom();

        _stateTimer?.cancel();
        _stateTimer = Timer(const Duration(seconds: 4), () {
          if (mounted && _currentState == AssistantState.speaking) {
            setState(() {
              _currentState = AssistantState.idle;
            });
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _currentState = AssistantState.error;
        _messages.add(
          ChatMessage(
            id: 'err_${DateTime.now().millisecondsSinceEpoch}',
            text: "We couldn't reach the business assistant. Please check your connection or try again.",
            isUser: false,
            timestamp: DateTime.now(),
            isError: true,
          ),
        );
      });
      _scrollToBottom();
    }
  }

  void _toggleMic() async {
    if (_currentState == AssistantState.listening) {
      _autoListenTimer?.cancel();
      // Transition from Listening to Transcribing
      setState(() {
        _currentState = AssistantState.transcribing;
      });

      try {
        final dummyPcm = List<int>.generate(2048, (i) => i % 128);
        final voiceResp = await _apiService.sendVoice(
          'M001',
          dummyPcm,
          language: _selectedLanguage,
        );

        if (!mounted) return;

        final recognizedText =
            voiceResp.transcript ?? 'Meri sales mein kya opportunity hai?';

        // Add transcribed user speech
        setState(() {
          _messages.add(
            ChatMessage(
              id: 'voice_input_${DateTime.now().millisecondsSinceEpoch}',
              text: recognizedText,
              isUser: true,
              timestamp: DateTime.now(),
            ),
          );
          _currentState = AssistantState.thinking;
        });
        _scrollToBottom();

        // Process response with identical business logic
        final isActionRequired =
            voiceResp.intent == 'ACTION_CONFIRMATION' ||
            voiceResp.actions.any((a) => a.type == 'confirmation') ||
            recognizedText.toLowerCase().contains('experiment start') ||
            recognizedText.toLowerCase().contains('start experiment') ||
            recognizedText.toLowerCase().contains('start karo');

        if (isActionRequired) {
          setState(() {
            _currentState = AssistantState.confirmation;
            _messages.add(
              ChatMessage(
                id: 'proposal_${DateTime.now().millisecondsSinceEpoch}',
                text: 'Tuesday 4–7 PM experiment start karun?',
                isUser: false,
                timestamp: DateTime.now(),
                actionProposal: ActionProposal(
                  title: 'Start Tuesday 4–7 PM experiment?',
                  description: '10% promotion on Tuesday 4 PM – 7 PM to recover 24% revenue drop.',
                  actionType: 'create_experiment',
                ),
              ),
            );
          });
          _scrollToBottom();
        } else {
          setState(() {
            _currentState = AssistantState.speaking;
            _messages.add(
              ChatMessage(
                id: voiceResp.messageId.isNotEmpty
                    ? voiceResp.messageId
                    : DateTime.now().millisecondsSinceEpoch.toString(),
                text: voiceResp.answer,
                isUser: false,
                timestamp: DateTime.now(),
              ),
            );
          });
          _scrollToBottom();

          _stateTimer?.cancel();
          _stateTimer = Timer(const Duration(seconds: 4), () {
            if (mounted && _currentState == AssistantState.speaking) {
              setState(() {
                _currentState = AssistantState.idle;
              });
            }
          });
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _currentState = AssistantState.error;
          _messages.add(
            ChatMessage(
              id: 'stt_err_${DateTime.now().millisecondsSinceEpoch}',
              text: "I couldn't hear that clearly. Try again or type your question.",
              isUser: false,
              timestamp: DateTime.now(),
              isError: true,
            ),
          );
        });
        _scrollToBottom();
      }
    } else {
      // Start Listening state
      setState(() {
        _currentState = AssistantState.listening;
      });

      // Auto-commit voice turn after 2 seconds if not manually stopped
      _autoListenTimer?.cancel();
      _autoListenTimer = Timer(const Duration(milliseconds: 2200), () {
        if (mounted && _currentState == AssistantState.listening) {
          _toggleMic();
        }
      });
    }
  }

  void _onConfirmAction(ActionProposal proposal) async {
    setState(() {
      proposal.isConfirmed = true;
      _currentState = AssistantState.idle;
    });

    try {
      // Call createExperiment exactly once
      await _apiService.createExperiment('OP001', 'M001');

      if (!mounted) return;

      setState(() {
        _messages.add(
          ChatMessage(
            id: 'exp_success_${DateTime.now().millisecondsSinceEpoch}',
            text: 'Experiment created ✓\nBaseline: ₹13,800 → Result: ₹17,250 (+25% Uplift)\nSynthetic demo simulation.',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
      _scrollToBottom();

      // Transition to Experiment Screen
      _navigationTimer?.cancel();
      _navigationTimer = Timer(const Duration(milliseconds: 600), () {
        if (mounted) {
          try {
            Navigator.pushNamed(context, AppRouter.experiment);
          } catch (_) {}
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _currentState = AssistantState.error;
        _messages.add(
          ChatMessage(
            id: 'exp_err_${DateTime.now().millisecondsSinceEpoch}',
            text: "Failed to execute experiment. Please try again.",
            isUser: false,
            timestamp: DateTime.now(),
            isError: true,
          ),
        );
      });
      _scrollToBottom();
    }
  }

  void _onCancelAction(ActionProposal proposal) {
    setState(() {
      proposal.isCancelled = true;
      _currentState = AssistantState.idle;
    });
    _scrollToBottom();
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
      body: KeyedSubtree(
        key: const Key('assistant_screen'),
        child: Column(
          children: [
            // Language selector bar
            _buildLanguageBar(),

            // Active status indicator banners (Listening, Transcribing, Thinking, Tool, Speaking, Error)
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
                    onConfirmAction:
                        message.actionProposal != null &&
                            !message.actionProposal!.isConfirmed &&
                            !message.actionProposal!.isCancelled
                        ? () => _onConfirmAction(message.actionProposal!)
                        : null,
                    onCancelAction:
                        message.actionProposal != null &&
                            !message.actionProposal!.isConfirmed &&
                            !message.actionProposal!.isCancelled
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
      ),
    );
  }

  Widget _buildLanguageBar() {
    final languages = ['Hinglish', 'हिंदी', 'English'];
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1.0),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
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
            ...languages.map((lang) {
              final isSelected = _selectedLanguage == lang;
              return Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: ChoiceChip(
                  label: Text(
                    lang,
                    style: TextStyle(
                      fontSize: 11.0,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.background,
                  onSelected: (_) => _handleLanguageChanged(lang),
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStateBanner() {
    if (_currentState == AssistantState.listening) {
      return Container(
        key: const Key('assistant_listening_indicator'),
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
    } else if (_currentState == AssistantState.transcribing) {
      return Container(
        key: const Key('assistant_transcribing_indicator'),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        color: AppColors.lightBlue.withValues(alpha: 0.7),
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
                'Transcribing audio speech...',
                style: TextStyle(
                  fontSize: 12.0,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (_currentState == AssistantState.thinking) {
      return Container(
        key: const Key('assistant_thinking_indicator'),
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
    } else if (_currentState == AssistantState.toolCall ||
        _currentState == AssistantState.toolExecution) {
      return Container(
        key: const Key('assistant_tool_indicator'),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        color: AppColors.lightBlue.withValues(alpha: 0.6),
        child: const Row(
          children: [
            Icon(Icons.build, size: 14.0, color: AppColors.secondaryBlue),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Preparing experiment parameters...',
                style: TextStyle(
                  fontSize: 12.0,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (_currentState == AssistantState.speaking) {
      return Container(
        key: const Key('assistant_speaking_indicator'),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        color: AppColors.successLight,
        child: Row(
          children: [
            const Icon(Icons.volume_up, size: 18.0, color: AppColors.success),
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
    } else if (_currentState == AssistantState.error) {
      return Container(
        key: const Key('assistant_error_banner'),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        color: AppColors.error.withValues(alpha: 0.1),
        child: const Row(
          children: [
            Icon(Icons.error_outline, size: 16.0, color: AppColors.error),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Unable to connect to assistant. Try again or type your query.',
                style: TextStyle(
                  fontSize: 12.0,
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
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
      'Meri sales mein kya opportunity hai?',
      'Experiment start karo',
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
              style: const TextStyle(fontSize: 12.0, color: AppColors.primary),
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
        border: Border(top: BorderSide(color: AppColors.divider, width: 1.0)),
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

          // Text Field (supporting both assistant_text_field and assistant_text_input)
          Expanded(
            child: KeyedSubtree(
              key: const Key('assistant_text_field'),
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
          ),
          const SizedBox(width: AppSpacing.xs),

          // Send Button
          IconButton(
            key: const Key('assistant_send_button'),
            icon: const Icon(Icons.send, color: AppColors.primary, size: 22.0),
            onPressed: () => _submitMessage(_textController.text),
          ),
        ],
      ),
    );
  }
}
