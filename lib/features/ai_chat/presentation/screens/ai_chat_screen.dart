import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../theme/app_colors.dart';
import '../providers/ai_chat_provider.dart';

/// Full-screen AI career advisor chat, opened from the floating AI button in
/// the bottom area of the main app shell.
class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  int _lastItemCount = 0;

  static const List<String> _suggestions = [
    'Recommend careers based on my skills',
    'Which scholarships am I eligible for?',
    'Suggest jobs or internships for me',
    'What should I learn over the next 3 months?',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        context.read<AiChatProvider>().start(userId);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send(AiChatProvider provider, [String? preset]) {
    final text = (preset ?? _controller.text).trim();
    if (text.isEmpty || !provider.isReady || provider.isSending) return;
    _controller.clear();
    provider.send(text);
  }

  void _scrollToBottomIfNeeded(int itemCount) {
    if (itemCount == _lastItemCount) return;
    _lastItemCount = itemCount;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AiChatProvider>();
    _scrollToBottomIfNeeded(provider.messages.length + (provider.isSending ? 1 : 0));

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Skillora AI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                Text('Career advisor', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'New chat',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: provider.isPreparing ? null : () => provider.newChat(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildBody(provider)),
          _buildInputBar(provider),
        ],
      ),
    );
  }

  Widget _buildBody(AiChatProvider provider) {
    if (provider.isPreparing) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 14),
            Text(
              'Loading your profile and app data...',
              style: TextStyle(color: AppColors.textSecondaryDark),
            ),
          ],
        ),
      );
    }

    if (provider.setupError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 40),
              const SizedBox(height: 12),
              Text(
                provider.setupError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.error),
              ),
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () => provider.newChat(),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    final messages = provider.messages;
    if (messages.isEmpty) return _buildWelcome(provider);

    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      itemCount: messages.length + (provider.isSending ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length) return const _TypingBubble();
        return _MessageBubble(message: messages[index]);
      },
    );
  }

  Widget _buildWelcome(AiChatProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 24),
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.lavenderLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primaryLight, size: 34),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Hi! I\'m Skillora AI',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ask me anything about careers, scholarships, jobs, internships and courses — tailored to you.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondaryDark, height: 1.4),
        ),
        const SizedBox(height: 24),
        ..._suggestions.map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: provider.isReady ? () => _send(provider, s) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(s, style: const TextStyle(color: Colors.white))),
                    const Icon(Icons.arrow_upward_rounded, size: 16, color: AppColors.primaryLight),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputBar(AiChatProvider provider) {
    final canSend = provider.isReady && !provider.isSending;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        decoration: const BoxDecoration(
          color: AppColors.navBackgroundDark,
          border: Border(top: BorderSide(color: AppColors.borderDark)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: provider.isReady,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Ask about careers, scholarships, jobs...',
                  hintStyle: const TextStyle(color: AppColors.textMutedDark, fontSize: 14),
                  filled: true,
                  fillColor: AppColors.inputBackgroundDark,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(color: AppColors.borderDark),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(color: AppColors.borderDark),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: canSend ? AppColors.primary : AppColors.surfaceDark,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: canSend ? () => _send(provider) : null,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final Color bg = isUser
        ? AppColors.primary
        : (message.isError ? AppColors.errorLight : AppColors.surfaceDark);
    final Color border = isUser
        ? AppColors.primary
        : (message.isError ? AppColors.error : AppColors.borderDark);
    final base = TextStyle(color: Colors.white, fontSize: 14.5, height: 1.45);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: Border.all(color: border),
        ),
        child: SelectableText.rich(_format(message.text, base)),
      ),
    );
  }

  /// Tiny markdown pass (Gemini replies with **bold**, "* " bullets and
  /// "#" headings) so no extra package is needed.
  TextSpan _format(String text, TextStyle base) {
    final spans = <InlineSpan>[];
    final lines = text.split('\n');
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i];
      final bullet = RegExp(r'^\s*[\*\-]\s+').firstMatch(line);
      if (bullet != null) line = '\u2022 ${line.substring(bullet.end)}';
      line = line.replaceFirst(RegExp(r'^#{1,6}\s*'), '');
      final parts = line.split('**');
      for (var j = 0; j < parts.length; j++) {
        spans.add(TextSpan(
          text: parts[j],
          style: j.isOdd ? base.copyWith(fontWeight: FontWeight.w700) : base,
        ));
      }
      if (i < lines.length - 1) spans.add(const TextSpan(text: '\n'));
    }
    return TextSpan(style: base, children: spans);
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 10),
            Text('AI is thinking...', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}