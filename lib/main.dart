import 'package:flutter/material.dart';

// import 'home.dart';
import 'movingStartPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ddm',
      home: StartPage(),
    );
  }
}
