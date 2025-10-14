import 'dart:developer';
import 'package:conversation_bubbles/conversation_bubbles.dart';
import 'package:http/http.dart' as http;

class BubblesService {
  static final instance = BubblesService._();
  BubblesService._();

  final _conversationBubblesPlugin = ConversationBubbles();

  bool _isInBubble = false;
  bool get isInBubble => _isInBubble;

  Future<void> init() async {
    _conversationBubblesPlugin.init(
      appIcon: '@mipmap/ic_launcher',
      fqBubbleActivity: 'com.example.test_socket.BubbleActivity',
    );
    _isInBubble = await _conversationBubblesPlugin.isInBubble();
    //
    final intentUri = await ConversationBubbles().getIntentUri();
    if (intentUri != null) {
    } else {
      log("Intent URL is null");
    }
  }

  Future<void> show(String messageText, {bool shouldAutoExpand = false}) async {
    final http.Response response = await http.get(
      Uri.parse(
        "https://images.unsplash.com/photo-1750785354752-2c234b875cdd?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      ),
    );
    await _conversationBubblesPlugin.show(
      notificationId: 1,
      body: messageText,
      contentUri: 'https://chat_and_noti.example.com/chat-screen/1',
      channel: NotificationChannel(
        id: 'chat',
        name: 'chat',
        description: 'chat',
      ),
      person: Person(id: "1", name: "name", icon: response.bodyBytes),
      isFromUser: shouldAutoExpand,
      shouldMinimize: shouldAutoExpand,
      appIcon: '@mipmap/ic_launcher',
      fqBubbleActivity: 'com.example.test_socket.BubbleActivity',
    );
  }
}
