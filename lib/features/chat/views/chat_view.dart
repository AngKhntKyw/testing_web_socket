import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_socket/features/auth/model/user_model.dart';
import 'package:test_socket/features/chat/controller/chat_controller.dart';

class ChatPage extends ConsumerWidget {
  // ✅ Changed to ConsumerWidget
  final UserModel recipient;
  final String currentUserId;

  const ChatPage({
    super.key,
    required this.recipient,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageController = TextEditingController();

    // ✅ WATCH the filtered messages for ONLY this partner
    final messages = ref.watch(chatPartnerMessagesProvider(recipient));

    // The rest of the logic is now much cleaner
    void sendMessage() {
      final message = messageController.text;
      if (message.isEmpty) return;

      ref.read(chatControllerProvider.notifier).sendMessage(recipient, message);
      messageController.clear();
    }

    // ... rest of the Scaffold UI ...
    return Scaffold(
      appBar: AppBar(title: Text(recipient.name)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length, // Use the watched list
              itemBuilder: (context, index) {
                final message = messages[index];
                final bool isMe = message.sender.userId == currentUserId;

                return Align(
                  // ... chat bubble UI ...
                  child: Text(
                    message.message,
                  ), // Use the Message object's property
                );
              },
            ),
          ),
          // ... input field using _sendMessage ...
        ],
      ),
    );
  }
}
