import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:test_socket/core/services/token_service.dart';
import 'package:test_socket/features/auth/model/user_model.dart';
// Assuming your TokenService file is available

// Callback type definition for when a message is received
typedef MessageReceivedCallback = void Function(Map<String, dynamic> message);

class StompClientService {
  // ✅ 1. Inject TokenService via constructor
  final TokenService _tokenService;

  StompClientService(this._tokenService); // Constructor injection

  late StompClient _stompClient;
  final String websocketUrl = 'ws://192.168.0.111:8080/ws';
  bool isConnected = false;

  // ✅ 2. Change to Future<void> and remove the 'token' argument
  Future<void> activate({required MessageReceivedCallback onMessage}) async {
    if (isConnected) return;

    // ✅ Retrieve token from the service
    final token = await _tokenService.getToken();

    if (token == null) {
      log('Stomp Service: JWT Token not found. Cannot connect.');
      // Handle scenario where token is missing (e.g., user not logged in)
      return;
    }

    final connectHeaders = {'Authorization': 'Bearer $token'};

    _stompClient = StompClient(
      config: StompConfig(
        url: websocketUrl,
        onConnect: (frame) => _onConnect(frame, onMessage),
        beforeConnect: () async => log('Stomp Service: Waiting to connect...'),
        onWebSocketError: (error) =>
            log('Stomp Service: WebSocket error: $error'),
        onStompError: (frame) =>
            log('Stomp Service: STOMP error: ${frame.body}'),
        onDisconnect: (frame) {
          log('Stomp Service: Disconnected');
          isConnected = false;
        },
        stompConnectHeaders: connectHeaders,
      ),
    );
    _stompClient.activate();
  }

  void _onConnect(StompFrame frame, MessageReceivedCallback onMessage) {
    // ... (rest of the _onConnect method is unchanged) ...
    log('Stomp Service: Connected');
    isConnected = true;

    // Subscribe to the private message queue
    _stompClient.subscribe(
      destination: '/user/queue/messages',
      callback: (frame) {
        if (frame.body != null) {
          try {
            final data = json.decode(frame.body!) as Map<String, dynamic>;
            onMessage(data);
          } catch (e) {
            log('Stomp Service: Error decoding message: $e');
          }
        }
      },
      headers: {},
    );
  }

  void sendMessage({required UserModel recipient, required String message}) {
    // ... (sendMessage method is unchanged) ...
    if (!_stompClient.connected) {
      log('Stomp Service: Client not connected, cannot send message.');
      return;
    }
    final messagePayload = json.encode({'to': recipient, 'message': message});
    _stompClient.send(
      destination: '/app/chat',
      body: messagePayload,
      headers: {},
    );
  }

  void deactivate() {
    // ... (deactivate method is unchanged) ...
    _stompClient.deactivate();
    isConnected = false;
  }
}

// ✅ 3. Update the Provider to inject the dependency
final stompClientServiceProvider = Provider((ref) {
  final tokenService = ref.read(tokenServiceProvider);
  return StompClientService(tokenService);
});
