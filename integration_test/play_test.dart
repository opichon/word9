import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:word9/state/game_controller.dart';
import 'package:word9/ui/word9_app.dart';

import '../test/support/fixed_random.dart';
import '../test/support/game_driver.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Opens the app on the real word data, at the test puzzle: the first Easy
  /// puzzle, `nominally` with centre `L`.
  Future<GameDriver> openTestPuzzle(WidgetTester tester) async {
    final controller = GameController(lang: 'en-GB', random: FixedRandom(0));
    addTearDown(controller.dispose);
    await tester.pumpWidget(Word9App(controller: controller));
    await tester.runAsync(controller.load);
    await tester.pump();
    return GameDriver(tester, controller);
  }

  testWidgets('AT-1: build and submit a word by tapping', (tester) async {
    final game = await openTestPuzzle(tester);

    await game.tapCentre();
    final o = await game.tapOuter('o');
    final a = await game.tapOuter('a');
    final m = await game.tapOuter('m');
    final y = await game.tapOuter('y');
    expect(game.entry, 'LOAMY');
    for (final index in [4, o, a, m, y]) {
      expect(game.isFree(index), isFalse);
    }

    await game.tapControl('Delete');
    expect(game.entry, 'LOAM');
    expect(game.isFree(y), isTrue);

    await game.tapControl('Enter');
    expect(game.message, '+ LOAM');
    expect(find.text('loam'), findsOneWidget);
    expect(find.text('1 of 22'), findsOneWidget);
  });

  testWidgets('AT-2: an invalid entry is rejected and cleared', (tester) async {
    final game = await openTestPuzzle(tester);

    await game.enter('mno');
    await game.tapControl('Enter');

    expect(game.message, '“LMNO” isn\'t in the word list');
    // Real frames don't land on a chosen moment, so sample across the shake.
    var furthest = 0.0;
    for (var frame = 0; frame < 15; frame++) {
      await tester.pump(const Duration(milliseconds: 30));
      furthest = max(furthest, game.shakeOffset.abs());
    }
    expect(furthest, greaterThan(0));
    expect(game.entry, isEmpty);
  });
}
