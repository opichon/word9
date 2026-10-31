import 'dart:math';

import 'package:flutter/material.dart';

import '../state/game_controller.dart';
import 'game_screen.dart';

/// The root of the app.
class Word9App extends StatefulWidget {
  const Word9App({this.controller, super.key});

  /// The game to show. Without one, the app loads its own.
  final GameController? controller;

  @override
  State<Word9App> createState() => _Word9AppState();
}

class _Word9AppState extends State<Word9App> {
  late final GameController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ??
        (GameController(lang: 'en-GB', random: Random())..load());
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameScreen(controller: _controller),
      title: 'word9',
    );
  }
}
