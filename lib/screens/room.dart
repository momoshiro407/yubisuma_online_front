import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/websocket_service.dart';
import 'game.dart';

class Room extends StatefulWidget {
  final String playerName;
  final String roomId;
  final bool isHost;

  const Room({
    super.key,
    required this.playerName,
    required this.roomId,
    this.isHost = false,
  });

  @override
  State<Room> createState() => _RoomState();
}

class _RoomState extends State<Room> {
  final WebSocketService _ws = WebSocketService();
  final List<String> _players = [];

  @override
  void initState() {
    super.initState();

    _ws.connect(widget.roomId, widget.playerName);

    _ws.stream?.listen((message) {
      final data = jsonDecode(message);

      if (data['type'] == 'room_state') {
        setState(() {
          _players
            ..clear()
            ..addAll(List<String>.from(data['players']));
        });
      }

      if (data['type'] == 'game_started') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => Game(
              roomId: widget.roomId,
              playerName: widget.playerName,
              ws: _ws,
            ),
          ),
        );
      }
    });

    _ws.send({
      'type': 'join_room',
      'room_id': widget.roomId,
      'player_name': widget.playerName,
    });
  }

  @override
  void dispose() {
    // GameScreenへ渡す場合は閉じない設計にする余地あり
    super.dispose();
  }

  void _startGame() {
    _ws.send({
      'type': 'start_game',
      'room_id': widget.roomId,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ルーム: ${widget.roomId}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              '参加者',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._players.map((name) => ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(name),
                )),
            const Spacer(),
            if (widget.isHost)
              FilledButton(
                onPressed: _startGame,
                child: const Text('ゲーム開始'),
              ),
          ],
        ),
      ),
    );
  }
}
