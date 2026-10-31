import 'package:flutter/material.dart';

/// The root of the app.
class Word9App extends StatelessWidget {
  const Word9App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(child: Center(child: Text('word9'))),
      ),
      title: 'word9',
    );
  }
}
