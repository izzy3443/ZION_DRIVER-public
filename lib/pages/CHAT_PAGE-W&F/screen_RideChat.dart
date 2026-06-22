import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion_driver_553/UI/TextField.dart';
import 'package:zion_driver_553/UI/tile_place.dart';
import 'package:zion_driver_553/theme.dart';
import 'package:zion_driver_553/pages/CHAT_PAGE-W&F/controller_RideChat.dart';
import 'package:zion_driver_553/models/chat_model.dart';

final isSendingLoadingProvider = StateProvider<bool>((ref) => false);
final messagesProvider = StateProvider<List<ChatMessage>>((ref) => []);

class ChatPage extends ConsumerStatefulWidget {
  final String rideId;
  final String currentUserId;
  final String receiverId;

  const ChatPage({
    required this.rideId,
    required this.currentUserId,
    required this.receiverId,
    super.key,
  });

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  late StreamSubscription<List<ChatMessage>> _subscription;
  bool _markReadPending = false;

  final List<String> _suggestions = [
    "waiting_for_you".tr(),
    "be_there_soon".tr(),
    "where_are_you".tr(),
    "looking_for_you".tr(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
      _markRead();
    });
    StartListening();
  }

  void StartListening() {
    _subscription = getMessages(widget.rideId).listen((msgs) {
      ref.read(messagesProvider.notifier).update((state) => msgs);
      final hasUnread = msgs.any((msg) =>
          msg.senderId != widget.currentUserId &&
          msg.readBy?[widget.currentUserId] == false);

      if (hasUnread && !_markReadPending) {
        _markReadPending = true;
        _markRead().then((_) => _markReadPending = false);
      }
    });
  }

  Future<void> _markRead() =>
      markMessagesAsRead(widget.rideId, widget.currentUserId);

  Future<void> _sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    _controller.clear();
    ref.read(isSendingLoadingProvider.notifier).state = true;

    try {
      await sendMessage(
        ref,
        trimmed,
        widget.currentUserId,
        widget.receiverId,
        widget.rideId,
      );
    } finally {
      if (mounted) ref.read(isSendingLoadingProvider.notifier).state = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    focusNode.dispose();
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(messagesProvider);
    final isSending = ref.watch(isSendingLoadingProvider);

    final lastMyMsgIndex =
        messages.lastIndexWhere((m) => m.senderId == widget.currentUserId);

    return Scaffold(
      backgroundColor: Themes.white0,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text("chat".tr(), style: Themes.headline2),
        backgroundColor: Themes.white1,
        foregroundColor: Themes.black0,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const _EmptyChat()
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (_, reversedIndex) {
                      final actualIndex = messages.length - 1 - reversedIndex;
                      final msg = messages[actualIndex];
                      final isMe = msg.senderId == widget.currentUserId;
                      final isLastMine = actualIndex == lastMyMsgIndex;
                      final isSeen = msg.readBy?[widget.receiverId] == true;

                      return _MessageBubble(
                        msg: msg,
                        isMe: isMe,
                        showSending: isSending && isMe && isLastMine,
                        showSeen: !isSending && isMe && isLastMine && isSeen,
                      );
                    },
                  ),
          ),
          _SuggestionBar(
            suggestions: _suggestions,
            onSend: _sendMessage,
          ),
          _InputBar(
            controller: _controller,
            focusNode: focusNode,
            isSending: isSending,
            onSend: () => _sendMessage(_controller.text),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _EmptyChat extends StatelessWidget {
  const _EmptyChat();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "no_messages_yet".tr(),
        textAlign: TextAlign.center,
        style: TextStyle(color: Themes.gray3, fontSize: 14.sp),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage msg;
  final bool isMe;
  final bool showSending;
  final bool showSeen;

  const _MessageBubble({
    required this.msg,
    required this.isMe,
    required this.showSending,
    required this.showSeen,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isMe ? Themes.tree_green : const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: Radius.circular(isMe ? 16.r : 4.r),
                  bottomRight: Radius.circular(isMe ? 4.r : 16.r),
                ),
              ),
              child: Text(
                msg.text,
                style: Themes.TextFieldMainText.copyWith(
                  color: isMe ? Colors.white : Themes.black0,
                ),
              ),
            ),
          ),
          if (showSending || showSeen)
            Padding(
              padding: const EdgeInsets.only(top: 3, right: 4),
              child: Text(
                showSending ? "sending".tr() : "seen".tr(),
                style: Themes.SuperSmallContainerText,
              ),
            ),
        ],
      ),
    );
  }
}

class _SuggestionBar extends StatelessWidget {
  final List<String> suggestions;
  final void Function(String) onSend;

  const _SuggestionBar({
    required this.suggestions,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        itemBuilder: (context, index) => PlaceTile(
          label: suggestions[index],
          onTap: () => onSend(suggestions[index]),
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSending;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12.r),
      child: Row(
        children: [
          Expanded(
            child: textField(
              focusNode: focusNode,
              controller,
              "type_a_message".tr(),
              icon: Icons.message,
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: isSending ? null : onSend,
            child: CircleAvatar(
              radius: 30,
              backgroundColor: isSending
                  ? Themes.tree_green.withOpacity(0.5)
                  : Themes.tree_green,
              child: isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send_outlined, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
