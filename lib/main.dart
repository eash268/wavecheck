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
        primaryColor: Colors.blue, // blue
        accentColor: const Color(0xFF52B950), // green
        backgroundColor: const Color(0XFFF7F6FB), // grey
      ),
      home: Home(),
    );
  }
}
