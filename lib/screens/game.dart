import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/websocket_service.dart';

class Game extends StatefulWidget {
  final String roomId;
  final String playerName;
  final WebSocketService ws;

  final List<String> players;
  final Map<String, dynamic> hands;
  final String currentTurn;

  const Game({
    super.key,
    required this.roomId,
    required this.playerName,
    required this.ws,
    required this.players,
    required this.hands,
    required this.currentTurn,
  });

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  late Map<String, int> hands;
  late String currentTurn;
  List<String> finished = [];
  int raisedFingers = 0;
  int declaredNumber = 0;
  bool get isMyTurn => currentTurn == widget.playerName;
  int? lastTotal;
  int? lastDeclared;
  bool? lastHit;
  String? lastHitPlayer;

  @override
  void initState() {
    super.initState();

    hands = Map<String, int>.from(widget.hands);
    currentTurn = widget.currentTurn;

    widget.ws.stream?.listen((message) {
      final data = jsonDecode(message);
      print("RECEIVED: $data");

      // -----------------------------
      // ラウンド結果
      // -----------------------------
      if (data['type'] == 'round_result') {
        setState(() {
          hands = Map<String, int>.from(data['hands']);
          finished = List<String>.from(data['finished']);
          currentTurn = data['next_turn'];
          lastTotal = data['total'];
          lastDeclared = data['declared'];
          lastHit = data['hit'];
          lastHitPlayer = data['hit_player'];
        });
      }

      // -----------------------------
      // ゲーム終了
      // -----------------------------
      if (data['type'] == 'game_finished') {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('ゲーム終了'),
            content: Text("順位: ${data['rankings']}"),
          ),
        );
      }
    });
  }

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // ① 現在ターン表示
            // =========================
            Text(
              isMyTurn ? "あなたのターン" : "$currentTurn のターン",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            if (lastTotal != null) ...[
              const SizedBox(height: 16),
              const Text(
                "前回結果",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text("宣言: $lastDeclared"),
              Text("合計: $lastTotal"),
              Text(lastHit == true ? "的中！" : "はずれ"),
              if (lastHitPlayer != null) Text("的中者: $lastHitPlayer"),
            ],

            const SizedBox(height: 16),

            // =========================
            // ② 各プレイヤーの手
            // =========================
            const Text(
              "各プレイヤーの手",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            ...hands.entries.map((entry) {
              return Text("${entry.key} : ${entry.value}本");
            }).toList(),

            const SizedBox(height: 16),

            // =========================
            // ③ 上がり表示
            // =========================
            const Text(
              "上がり",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            Text(
              finished.isEmpty ? "なし" : finished.join(", "),
            ),

            const SizedBox(height: 32),

            // =========================
            // ④ 指選択UI
            // =========================
            const Text('指を選択'),
            const SizedBox(height: 8),

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

            const SizedBox(height: 24),

            // =========================
            // ⑤ 数字宣言（ターンのみ）
            // =========================
            const Text('宣言する数字'),

            Slider(
              value: declaredNumber.toDouble(),
              min: 0,
              max: 10,
              divisions: 10,
              label: declaredNumber.toString(),
              onChanged: isMyTurn
                  ? (value) {
                      setState(() {
                        declaredNumber = value.toInt();
                      });
                    }
                  : null,
            ),

            Text(
              declaredNumber.toString(),
              style: const TextStyle(fontSize: 24),
            ),

            const Spacer(),

            // =========================
            // ⑥ 決定ボタン
            // =========================
            FilledButton(
              onPressed: () {
                widget.ws.send({
                  'type': 'submit_input',
                  'raised_fingers': raisedFingers,
                  'declared_number': isMyTurn ? declaredNumber : -1,
                });
              },
              child: const Text('決定'),
            ),
          ],
        ),
      ),
    );
  }
}
