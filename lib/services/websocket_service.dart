import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  StreamController<dynamic>? _controller;

  Stream<dynamic>? get stream => _controller?.stream;

  void connect(String roomId, String playerName) {
    final uri = Uri.parse(
      'ws://localhost:8000/ws/$roomId?player_name=$playerName',
    );

    _channel = WebSocketChannel.connect(uri);
    _controller = StreamController<dynamic>.broadcast();

    _channel!.stream.listen(
      (message) {
        _controller?.add(message);
      },
      onError: (error) {
        _controller?.addError(error);
      },
      onDone: () {
        _controller?.close();
      },
    );
  }

  void send(Map<String, dynamic> data) {
    _channel?.sink.add(jsonEncode(data));
  }

  void dispose() {
    _channel?.sink.close();
    _controller?.close();
  }
}
