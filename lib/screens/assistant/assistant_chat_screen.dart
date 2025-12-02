import 'package:flutter/material.dart';

import '../../models/assistant_message.dart';
import '../../services/openai_assistant_service.dart';

class AssistantChatScreen extends StatefulWidget {
  const AssistantChatScreen({super.key, required this.persona});

  final AssistantPersona persona;

  @override
  State<AssistantChatScreen> createState() => _AssistantChatScreenState();
}

class _AssistantChatScreenState extends State<AssistantChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final OpenAIAssistantService _assistantService;

  final List<AssistantMessage> _messages = [];
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _assistantService = OpenAIAssistantService();
    _messages.add(
      AssistantMessage(
        role: AssistantRole.assistant,
        content: _greetingFor(widget.persona),
        includeInContext: false,
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _assistantService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(_titleFor(widget.persona))),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              itemCount: _messages.length + (_isSending ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isSending && index == _messages.length) {
                  return _buildTypingIndicator(theme);
                }
                final message = _messages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: _buildMessageBubble(message, theme),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Type your question...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _isSending ? null : _sendMessage,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(AssistantMessage message, ThemeData theme) {
    final isUser = message.isUser;
    final backgroundColor = isUser
        ? const Color(0xFF1A1A2E)
        : theme.colorScheme.surfaceContainerHighest.withOpacity(0.8);
    final textColor = isUser
        ? const Color(0xFFFFD700)
        : theme.colorScheme.onSurface;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(18).copyWith(
              bottomLeft: Radius.circular(isUser ? 18 : 6),
              bottomRight: Radius.circular(isUser ? 6 : 18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              message.content,
              style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.7),
          borderRadius: BorderRadius.circular(
            18,
          ).copyWith(bottomRight: const Radius.circular(6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text('Assistant is typing...', style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _messages.add(AssistantMessage(role: AssistantRole.user, content: text));
      _isSending = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final reply = await _assistantService.sendMessage(
        persona: widget.persona,
        messages: List<AssistantMessage>.from(_messages),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _messages.add(
          AssistantMessage(role: AssistantRole.assistant, content: reply),
        );
      });
    } on OpenAIAssistantException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _messages.add(
          AssistantMessage(
            role: AssistantRole.assistant,
            content: 'I could not process your message: ${error.message}',
            includeInContext: false,
          ),
        );
      });

      _showErrorFeedback(error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }

    const fallback =
      'We could not reach the assistant. Please try again in a few seconds.';
      setState(() {
        _messages.add(
          const AssistantMessage(
            role: AssistantRole.assistant,
            content: fallback,
            includeInContext: false,
          ),
        );
      });

      _showErrorFeedback(fallback);
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSending = false;
      });

      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _showErrorFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  String _titleFor(AssistantPersona persona) {
    switch (persona) {
      case AssistantPersona.client:
        return 'VaneLux Assistant';
      case AssistantPersona.driver:
        return 'Driver Assistant';
    }
  }

  String _greetingFor(AssistantPersona persona) {
    switch (persona) {
      case AssistantPersona.client:
        return 'Hello, I am your VaneLux digital assistant. I can help with bookings, fares, route ideas, and trip updates.';
      case AssistantPersona.driver:
        return 'Hello, I am your VaneLux assistant for chauffeurs. Ask me about best practices, protocols, or operational support.';
    }
  }
}
