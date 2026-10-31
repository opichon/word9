import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word9/state/game_controller.dart';
import 'package:word9/state/word_data.dart';
import 'package:word9/ui/word9_app.dart';

import '../support/fixed_random.dart';
import '../support/game_driver.dart';

void main() {
  final data = WordData.fromJson(
    jsonDecode(File('test/fixtures/word_data.json').readAsStringSync())
        as Map<String, dynamic>,
  );

  Future<GameDriver> open(WidgetTester tester) async {
    final controller = GameController(lang: 'en-GB', random: FixedRandom(0))
      ..start(data);
    addTearDown(controller.dispose);
    await tester.pumpWidget(Word9App(controller: controller));
    return GameDriver(tester, controller);
  }

  group('CT-1: controls on an empty entry', () {
    for (final control in ['Enter', 'Delete']) {
      testWidgets('$control does nothing', (tester) async {
        final game = await open(tester);
        var changes = 0;
        game.controller.addListener(() => changes++);

        await game.tapControl(control);

        expect(changes, 0);
        expect(game.message, isNull);
        expect(game.controller.shakes, 0);
      });
    }
  });

  testWidgets('CT-9: hardware keys change nothing, and no keyboard opens', (
    tester,
  ) async {
    final game = await open(tester);
    await game.enter('oam');
    var changes = 0;
    game.controller.addListener(() => changes++);

    for (final key in [
      LogicalKeyboardKey.keyN,
      LogicalKeyboardKey.enter,
      LogicalKeyboardKey.backspace,
      LogicalKeyboardKey.escape,
    ]) {
      await tester.sendKeyEvent(key);
    }
    await tester.pump();

    expect(changes, 0);
    expect(game.entry, 'LOAM');
    expect(tester.testTextInput.isVisible, isFalse);
    expect(find.byType(EditableText), findsNothing);
  });
}
