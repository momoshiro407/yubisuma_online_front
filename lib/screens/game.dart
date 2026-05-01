import 'package:flutter/material.dart';
import '../services/websocket_service.dart';

class Game extends StatefulWidget {
  final String roomId;
  final String playerName;
  final WebSocketService ws;

  const Game({
    super.key,
    required this.roomId,
    required this.playerName,
    required this.ws,
  });

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  int raisedFingers = 0;
  int declaredNumber = 0;

  void _submit() {
    widget.ws.send({
      'type': 'submit_input',
      'room_id': widget.roomId,
      'player_name': widget.playerName,
      'raised_fingers': raisedFingers,
      'declared_number': declaredNumber,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('対戦中'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              '指を選択',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('0本')),
                ButtonSegment(value: 1, label: Text('1本')),
                ButtonSegment(value: 2, label: Text('2本')),
              ],
              selected: {raisedFingers},
              onSelectionChanged: (value) {
                setState(() {
                  raisedFingers = value.first;
                });
              },
            ),
            const SizedBox(height: 32),
            const Text('宣言する数字'),
            Slider(
              value: declaredNumber.toDouble(),
              min: 0,
              max: 10,
              divisions: 10,
              label: declaredNumber.toString(),
              onChanged: (value) {
                setState(() {
                  declaredNumber = value.toInt();
                });
              },
            ),
            Text(
              declaredNumber.toString(),
              style: const TextStyle(fontSize: 32),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _submit,
              child: const Text('決定'),
            ),
          ],
        ),
      ),
    );
  }
}
