enum AssistantState {
  idle,
  listening,
  transcribing,
  thinking,
  toolCall,
  toolExecution,
  confirmation,
  response,
  speaking,
  error,
}

class ActionProposal {
  final String title;
  final String description;
  final String actionType;
  final String? actionId;
  final Map<String, dynamic> arguments;
  bool isConfirmed;
  bool isCancelled;

  ActionProposal({
    required this.title,
    required this.description,
    required this.actionType,
    this.actionId,
    this.arguments = const {},
    this.isConfirmed = false,
    this.isCancelled = false,
  });
}

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final ActionProposal? actionProposal;
  final String? toolName;
  final Map<String, dynamic>? toolParams;
  final bool isError;
  final String? audioUrl;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.actionProposal,
    this.toolName,
    this.toolParams,
    this.isError = false,
    this.audioUrl,
  });
}
