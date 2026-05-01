import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;

  Stream<dynamic>? get stream => _channel?.stream;

  void connect(String roomId, String playerName) {
    final uri = Uri.parse(
      'ws://localhost:8000/ws/$roomId?player_name=$playerName',
    );

    _channel = WebSocketChannel.connect(uri);
  }

  void send(Map<String, dynamic> data) {
    _channel?.sink.add(jsonEncode(data));
  }

  void dispose() {
    _channel?.sink.close();
  }
}
