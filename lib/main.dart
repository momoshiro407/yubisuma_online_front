import 'package:flutter/material.dart';
import 'screens/home.dart';

void main() {
  runApp(const YubisumaApp());
}

class YubisumaApp extends StatelessWidget {
  const YubisumaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '指スマオンライン',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}
