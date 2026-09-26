enum AssistantState {
  idle,
  listening,
  thinking,
  toolExecution,
  confirmation,
  speaking,
}

class ActionProposal {
  final String title;
  final String description;
  final String actionType;
  bool isConfirmed;
  bool isCancelled;

  ActionProposal({
    required this.title,
    required this.description,
    required this.actionType,
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

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.actionProposal,
    this.toolName,
    this.toolParams,
  });
}
