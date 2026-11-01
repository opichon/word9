import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word9/game/word_validation.dart';
import 'package:word9/state/game_controller.dart';

/// Taps tiles and controls the way a player does.
class GameDriver {
  GameDriver(this.tester, this.controller);

  final GameController controller;
  final WidgetTester tester;

  Finder tile(int index) => find.byKey(ValueKey('tile-$index'));

  /// The text of the entry.
  String get entry => tester
      .widget<Text>(find.byKey(const ValueKey('entry')))
      .textSpan!
      .toPlainText();

  /// The text of the message, or null when there is none.
  String? get message {
    final finder = find.byKey(const ValueKey('message'));
    return finder.evaluate().isEmpty ? null : tester.widget<Text>(finder).data;
  }

  /// The horizontal offset of the entry at this moment.
  double get shakeOffset => tester
      .widget<Transform>(find.byKey(const ValueKey('entry-shake')))
      .transform
      .getTranslation()
      .x;

  bool isFree(int index) =>
      tester.widget<ButtonStyleButton>(tile(index)).onPressed != null;

  Future<void> tapCentre() => _tap(tile(centreIndex));

  /// Taps a free outer tile showing [letter], and returns its position.
  Future<int> tapOuter(String letter) async {
    final board = controller.board!;
    for (var index = 0; index < board.letters.length; index++) {
      if (index != centreIndex &&
          board.letters[index] == letter &&
          !board.picked.contains(index)) {
        await _tap(tile(index));
        return index;
      }
    }
    throw StateError('no free outer tile for $letter');
  }

  /// Taps the centre tile, then outer tiles for [letters].
  Future<void> enter(String letters) async {
    await tapCentre();
    for (final letter in letters.split('')) {
      await tapOuter(letter);
    }
  }

  Future<void> tapControl(String label) => _tap(find.text(label));

  Future<void> _tap(Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pump();
  }
}
