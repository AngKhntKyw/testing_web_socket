import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_socket/core/services/stomp_client_service.dart';
import 'package:test_socket/features/auth/model/user_model.dart';

class ChatRepository {
  final StompClientService _stompService;

  ChatRepository(this._stompService);

  // Method to initialize the connection
  // It receives the handler function from the controller
  void connectAndListen(void Function(Map<String, dynamic> data) onMessage) {
    _stompService.activate(
      onMessage: (message) {
        // Here, you could filter, validate, or transform the message before passing it
        log('Chat Repository: Message received and passing up.');
        onMessage(message);
      },
    );
  }

  // Method to send a message
  void sendMessage({required UserModel recipient, required String message}) {
    _stompService.sendMessage(recipient: recipient, message: message);
  }

  // Method to close the connection
  void disconnect() {
    _stompService.deactivate();
  }
}

// Riverpod Provider for the Repository
final chatRepositoryProvider = Provider((ref) {
  final stompService = ref.read(stompClientServiceProvider);
  return ChatRepository(stompService);
});
