import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_socket/features/auth/model/user_model.dart';
import 'package:test_socket/features/chat/model/message_model.dart';
import 'package:test_socket/features/chat/repository/chat_repository.dart';
import 'package:test_socket/init_noti.dart';

// Notifier to hold the state of all messages (This is a simplified global list)
class ChatController extends Notifier<List<MessageModel>> {
  @override
  List<MessageModel> build() {
    return []; // Initial empty list of messages
  }

  // Method called by the Repository when a message arrives
  void _addMessageFromSocket(Map<String, dynamic> data, String currentUserId) {
    final newMessage = MessageModel.fromJson(data);

    // Add the message to the state list
    state = [...state, newMessage];

    // Handle notification (Side effect)
    if (newMessage.sender.userId != currentUserId) {
      LocalNotificationService.instance.showNoti(
        title: newMessage.sender.name,
        body: newMessage.message,
      );
    }
  }

  // Method called by the UI to send a message
  void sendMessage(UserModel recipient, String content) {
    ref
        .read(chatRepositoryProvider)
        .sendMessage(recipient: recipient, message: content);
    // Note: We rely on the socket echo/server response (received via _addMessageFromSocket)
    // to actually update the UI, not manually add the message here.
  }

  // Method to initialize the connection and start listening
  void initialize(String currentUserId) {
    ref
        .read(chatRepositoryProvider)
        .connectAndListen((data) => _addMessageFromSocket(data, currentUserId));
  }

  void disconnect() {
    ref.read(chatRepositoryProvider).disconnect();
    state = []; // Clear messages on disconnect/logout
  }
}

final chatControllerProvider =
    NotifierProvider<ChatController, List<MessageModel>>(ChatController.new);

// Helper Provider to filter messages for a specific chat partner
// Use this in your ChatPage.dart to show only relevant messages
final chatPartnerMessagesProvider =
    Provider.family<List<MessageModel>, UserModel>((ref, recipient) {
      final allMessages = ref.watch(chatControllerProvider);
      final currentUserId = 'YOUR_CURRENT_USER_ID';

      return allMessages.where((msg) {
        // Message is either from me to the partner OR from the partner to me
        return (msg.sender.userId == currentUserId &&
                msg.recipient.userId == recipient.userId) ||
            (msg.sender.userId == recipient.userId &&
                msg.recipient.userId == currentUserId);
      }).toList();
    });
