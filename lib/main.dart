import 'package:flutter/material.dart';
import 'package:WaveCheck/pages/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WaveCheck',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'OpenSans',
        primaryColor: const Color(0xFF46A4E4),
        accentColor: const Color(0xFF68B9A8),
      ),
      home: Home(),
    );
  }
}
