import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:test_socket/init_noti.dart';

class ChatPage extends StatefulWidget {
  final String name;
  final String token;
  final String currentUser;

  const ChatPage({
    super.key,
    required this.name,
    required this.token,
    required this.currentUser,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late StompClient stompClient;
  final String websocketUrl = 'ws://192.168.0.111:8080/ws';
  final TextEditingController messageController = TextEditingController();
  final List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    connectWebSocket();
  }

  void connectWebSocket() {
    final connectHeaders = {'Authorization': 'Bearer ${widget.token}'};

    stompClient = StompClient(
      config: StompConfig(
        url: websocketUrl,
        onConnect: onConnect,
        beforeConnect: () async {
          log('waiting to connect...');
        },
        onWebSocketError: (dynamic error) => log('WebSocket error: $error'),
        onStompError: (StompFrame frame) => log('STOMP error: ${frame.body}'),
        onDisconnect: (StompFrame frame) => log('Disconnected'),
        stompConnectHeaders: connectHeaders,
      ),
    );

    stompClient.activate();
  }

  void onConnect(StompFrame frame) {
    log('Connected: ${frame.headers}');

    stompClient.subscribe(
      destination: '/user/queue/messages',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          try {
            final data = json.decode(frame.body!);
            log('New message: $data');
            setState(() {
              messages.add(data);
            });
            LocalNotificationService.instance.showNoti(
              title: "New Message",
              body: data['message'],
            );
          } catch (e) {
            log('Error decoding message body: $e');
          }
        }
      },
      headers: {},
    );
  }

  void _sendMessage() {
    final recipient = widget.name;
    final message = messageController.text;

    if (message.isEmpty) return;

    if (stompClient.connected) {
      final messagePayload = json.encode({'to': recipient, 'message': message});

      stompClient.send(
        destination: '/app/chat',
        body: messagePayload,
        headers: {},
      );

      setState(() {
        messages.add({
          'to': recipient,
          'message': message,
          'from': widget.currentUser,
        });
      });

      messageController.clear();
    } else {
      log('STOMP client is not connected.');
    }
  }

  @override
  void dispose() {
    stompClient.deactivate();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final bool isMe = message['from'] == widget.currentUser;

                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Card(
                    color: isMe ? Colors.blue[100] : Colors.grey[300],
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(message['message'] ?? ''),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.all(15),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
