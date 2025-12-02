enum AssistantRole { user, assistant, system }

class AssistantMessage {
  const AssistantMessage({
    required this.role,
    required this.content,
    this.includeInContext = true,
  });

  final AssistantRole role;
  final String content;
  final bool includeInContext;

  bool get isUser => role == AssistantRole.user;

  bool get isAssistant => role == AssistantRole.assistant;

  Map<String, String> toRequestMap() {
    return {'role': role.name, 'content': content};
  }
}
