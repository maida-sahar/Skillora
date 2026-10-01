import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../../services/gemini_service.dart';
import '../../data/ai_chat_context_builder.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isError;

  const ChatMessage({required this.text, required this.isUser, this.isError = false});
}

/// Holds the AI advisor conversation. Registered at app level so the chat
/// survives closing and re-opening the screen; it resets automatically if a
/// different user signs in, or when "New chat" is tapped.
class AiChatProvider with ChangeNotifier {
  final GeminiService _gemini;
  final AiChatContextBuilder _contextBuilder;

  AiChatProvider({GeminiService? gemini, AiChatContextBuilder? contextBuilder})
      : _gemini = gemini ?? GeminiService(),
        _contextBuilder = contextBuilder ?? AiChatContextBuilder();

  final List<ChatMessage> _messages = [];
  ChatSession? _session;
  String? _userId;
  bool _isPreparing = false;
  bool _isSending = false;
  String? _setupError;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isPreparing => _isPreparing;
  bool get isSending => _isSending;
  String? get setupError => _setupError;
  bool get isReady => _session != null && !_isPreparing;

  /// Called when the chat screen opens. Keeps the existing conversation if it
  /// belongs to the same user, otherwise starts fresh.
  Future<void> start(String userId) async {
    if (_isPreparing) return;
    if (_userId == userId && _session != null) return;
    await _prepare(userId);
  }

  Future<void> newChat() async {
    final id = _userId;
    if (id == null || _isPreparing) return;
    await _prepare(id);
  }

  Future<void> _prepare(String userId) async {
    _userId = userId;
    _isPreparing = true;
    _isSending = false;
    _setupError = null;
    _session = null;
    _messages.clear();
    notifyListeners();

    try {
      final context = await _contextBuilder.build(userId);
      _session = _gemini.startChat(contextPrompt: context);
    } catch (e) {
      _setupError = _clean(e);
    }
    _isPreparing = false;
    notifyListeners();
  }

  Future<void> send(String text) async {
    final message = text.trim();
    final session = _session;
    if (message.isEmpty || session == null || _isSending) return;

    _messages.add(ChatMessage(text: message, isUser: true));
    _isSending = true;
    notifyListeners();

    try {
      final response = await session.sendMessage(Content.text(message));
      final reply = response.text?.trim() ?? '';
      _messages.add(ChatMessage(
        text: reply.isEmpty ? 'The AI didn\'t return an answer. Try rephrasing your question.' : reply,
        isUser: false,
        isError: reply.isEmpty,
      ));
    } catch (e) {
      debugPrint('AI chat send error: $e');
      _messages.add(ChatMessage(
        text: 'Couldn\'t get a response from the AI.\n${_clean(e)}',
        isUser: false,
        isError: true,
      ));
    }
    _isSending = false;
    notifyListeners();
  }

  String _clean(Object e) {
    final text = e.toString().replaceFirst('Exception: ', '');
    return text.length > 220 ? '${text.substring(0, 220)}...' : text;
  }
}