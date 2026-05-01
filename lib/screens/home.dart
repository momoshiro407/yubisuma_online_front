import 'package:flutter/material.dart';
import 'room.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _playerNameController = TextEditingController();
  final _roomIdController = TextEditingController();

  @override
  void dispose() {
    _playerNameController.dispose();
    _roomIdController.dispose();
    super.dispose();
  }

  void _joinRoom() {
    final playerName = _playerNameController.text.trim();
    final roomId = _roomIdController.text.trim();

    if (playerName.isEmpty || roomId.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Room(
          playerName: playerName,
          roomId: roomId,
        ),
      ),
    );
  }

  void _createRoom() {
    final playerName = _playerNameController.text.trim();
    if (playerName.isEmpty) return;

    final roomId =
        DateTime.now().millisecondsSinceEpoch.toString().substring(8);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Room(
          playerName: playerName,
          roomId: roomId,
          isHost: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('指スマオンライン'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _playerNameController,
              decoration: const InputDecoration(
                labelText: 'プレイヤー名',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _roomIdController,
              decoration: const InputDecoration(
                labelText: 'ルームID',
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _joinRoom,
              child: const Text('ルームに参加'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _createRoom,
              child: const Text('ルームを作成'),
            ),
          ],
        ),
      ),
    );
  }
}
