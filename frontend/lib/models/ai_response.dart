class RecommendationResponse {
  final String opportunityId;
  final String title;
  final String explanation;
  final String recommendation;
  final String experimentPeriod;
  final String estimatedUpliftRange;

  RecommendationResponse({
    required this.opportunityId,
    required this.title,
    required this.explanation,
    required this.recommendation,
    required this.experimentPeriod,
    this.estimatedUpliftRange = '+15% to +30%',
  });

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) {
    return RecommendationResponse(
      opportunityId: json['opportunity_id'] ?? '',
      title: json['title'] ?? '',
      explanation: json['explanation'] ?? json['reason'] ?? '',
      recommendation: json['recommendation'] ?? '',
      experimentPeriod: json['experiment_period'] ?? '',
      estimatedUpliftRange: json['estimated_uplift_range'] ?? '+15% to +30%',
    );
  }
}

/// Structured action payload returned by the Unified Conversational Agent
class AgentAction {
  final String id;
  final String type; // 'navigate', 'tool', 'suggestion', 'confirmation'
  final String label;
  final String? tool;
  final Map<String, dynamic> arguments;
  final bool requiresConfirmation;
  final String? confirmationPrompt;

  const AgentAction({
    required this.id,
    this.type = 'suggestion',
    required this.label,
    this.tool,
    this.arguments = const {},
    this.requiresConfirmation = false,
    this.confirmationPrompt,
  });

  factory AgentAction.fromJson(Map<String, dynamic> json) {
    return AgentAction(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'suggestion',
      label: json['label']?.toString() ?? '',
      tool: json['tool']?.toString(),
      arguments: json['arguments'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['arguments'])
          : const {},
      requiresConfirmation: json['requires_confirmation'] == true,
      confirmationPrompt: json['confirmation_prompt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'label': label,
    'tool': tool,
    'arguments': arguments,
    'requires_confirmation': requiresConfirmation,
    'confirmation_prompt': confirmationPrompt,
  };
}

/// Audio metadata returned from STT / TTS endpoints
class AudioMeta {
  final bool audioAvailable;
  final String? audioUrl;
  final String? audioId;
  final String? mimeType;
  final double? durationSec;
  final String? errorMessage;

  const AudioMeta({
    this.audioAvailable = false,
    this.audioUrl,
    this.audioId,
    this.mimeType = 'audio/wav',
    this.durationSec,
    this.errorMessage,
  });

  factory AudioMeta.fromJson(Map<String, dynamic> json) {
    return AudioMeta(
      audioAvailable: json['audio_available'] == true,
      audioUrl: json['audio_url']?.toString(),
      audioId: json['audio_id']?.toString(),
      mimeType: json['mime_type']?.toString() ?? 'audio/wav',
      durationSec: (json['duration_sec'] as num?)?.toDouble(),
      errorMessage: json['error_message']?.toString(),
    );
  }
}

/// Unified Conversation Response from backend AI service
class AiAskResponse {
  final String conversationId;
  final String messageId;
  final String answer;
  final String? transcript;
  final String? detectedLanguage;
  final String? intent;
  final List<AgentAction> actions;
  final List<String> suggestedActions;
  final AudioMeta? audio;
  final Map<String, dynamic> metadata;

  const AiAskResponse({
    this.conversationId = '',
    this.messageId = '',
    required this.answer,
    this.transcript,
    this.detectedLanguage = 'hinglish',
    this.intent = 'ANALYTICS_QUERY',
    this.actions = const [],
    this.suggestedActions = const [],
    this.audio,
    this.metadata = const {},
  });

  factory AiAskResponse.fromJson(Map<String, dynamic> json) {
    final rawAnswer =
        json['answer'] ??
        (json['response'] is Map ? json['response']['text'] : null) ??
        '';

    final rawTranscript =
        (json['input'] is Map ? json['input']['transcript'] : null) ??
        json['transcript'];

    final rawDetectedLang =
        (json['input'] is Map ? json['input']['detected_language'] : null) ??
        (json['response'] is Map ? json['response']['language'] : null);

    List<AgentAction> actionsList = [];
    if (json['actions'] is List) {
      actionsList = (json['actions'] as List)
          .whereType<Map<String, dynamic>>()
          .map((a) => AgentAction.fromJson(a))
          .toList();
    }

    List<String> suggested = [];
    if (json['suggested_actions'] is List) {
      suggested = (json['suggested_actions'] as List)
          .map((e) => e.toString())
          .toList();
    }

    AudioMeta? audioMeta;
    if (json['audio'] is Map<String, dynamic>) {
      audioMeta = AudioMeta.fromJson(json['audio']);
    }

    return AiAskResponse(
      conversationId: json['conversation_id']?.toString() ?? '',
      messageId: json['message_id']?.toString() ?? '',
      answer: rawAnswer.toString(),
      transcript: rawTranscript?.toString(),
      detectedLanguage: rawDetectedLang?.toString() ?? 'hinglish',
      intent: json['intent']?.toString() ?? 'ANALYTICS_QUERY',
      actions: actionsList,
      suggestedActions: suggested,
      audio: audioMeta,
      metadata: json['metadata'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['metadata'])
          : const {},
    );
  }
}

/// Action execution result payload
class ActionExecuteResponse {
  final bool success;
  final String actionId;
  final String tool;
  final String status;
  final Map<String, dynamic> result;
  final String message;

  const ActionExecuteResponse({
    this.success = true,
    required this.actionId,
    required this.tool,
    this.status = 'success',
    this.result = const {},
    required this.message,
  });

  factory ActionExecuteResponse.fromJson(Map<String, dynamic> json) {
    return ActionExecuteResponse(
      success: json['success'] != false,
      actionId: json['action_id']?.toString() ?? '',
      tool: json['tool']?.toString() ?? '',
      status: json['status']?.toString() ?? 'success',
      result: json['result'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['result'])
          : const {},
      message: json['message']?.toString() ?? '',
    );
  }
}

/// Assistant capabilities response
class CapabilitiesResponse {
  final bool textChat;
  final bool voiceInput;
  final bool voiceOutput;
  final bool realtime;
  final List<String> languages;
  final List<String> audioFormats;
  final List<String> toolsAvailable;

  const CapabilitiesResponse({
    this.textChat = true,
    this.voiceInput = true,
    this.voiceOutput = true,
    this.realtime = true,
    this.languages = const ['en', 'hi', 'hinglish'],
    this.audioFormats = const ['audio/wav', 'audio/webm'],
    this.toolsAvailable = const [],
  });

  factory CapabilitiesResponse.fromJson(Map<String, dynamic> json) {
    return CapabilitiesResponse(
      textChat: json['text_chat'] != false,
      voiceInput: json['voice_input'] != false,
      voiceOutput: json['voice_output'] != false,
      realtime: json['realtime'] != false,
      languages:
          (json['languages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['en', 'hi', 'hinglish'],
      audioFormats:
          (json['audio_formats'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['audio/wav', 'audio/webm'],
      toolsAvailable:
          (json['tools_available'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}
