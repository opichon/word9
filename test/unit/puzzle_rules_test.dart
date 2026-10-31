import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:word9/game/banners.dart';
import 'package:word9/game/board.dart';
import 'package:word9/game/puzzles.dart';

import '../support/fixed_random.dart';

void main() {
  final book = PuzzleBook.fromJson(
    jsonDecode(File('test/fixtures/word_data.json').readAsStringSync())
        as Map<String, dynamic>,
  );

  group('UT-3: new puzzle', () {
    test('comes from the chosen level', () {
      for (final (level, seed) in [
        (1, 'nominally'),
        (2, 'bacterial'),
        (3, 'souvenirs'),
      ]) {
        final puzzle = book.pick(
          level: level,
          random: FixedRandom(0),
          testMode: false,
        );
        expect(puzzle.seed, seed);
        expect(puzzle.level, level);
      }
    });

    test('puts the centre letter in the middle of all nine', () {
      final puzzle = book.pick(
        level: 1,
        random: FixedRandom(0),
        testMode: false,
      );
      final board = Board.deal(puzzle, Random(1));

      expect(board.letters.length, 9);
      expect(board.letters[4], 'l');
      expect([...board.letters]..sort(), 'nominally'.split('')..sort());
    });

    test('test mode draws from the test pool at Easy, whatever the level', () {
      final puzzle = book.pick(
        level: 3,
        random: FixedRandom(1),
        testMode: true,
      );

      expect(puzzle.seed, 'communism');
      expect(puzzle.level, 1);
    });

    test('the same index gives the same puzzle again: no play history', () {
      Puzzle pick() =>
          book.pick(level: 1, random: FixedRandom(0), testMode: false);

      expect(identical(pick(), pick()), isTrue);
    });
  });

  group('UT-4: shuffle and delete', () {
    const letters = ['n', 'o', 'm', 'i', 'l', 'n', 'a', 'l', 'y'];

    test('shuffle empties the entry and permutes only the outer tiles', () {
      final board = Board(letters: [...letters], picked: [4, 1]);

      board.shuffle(Random(3));

      expect(board.picked, isEmpty);
      expect(board.letters[4], 'l');
      expect(board.letters, isNot(letters));
      expect([...board.letters]..sort(), [...letters]..sort());
    });

    test('delete removes the last tile, and does nothing when empty', () {
      final board = Board(letters: [...letters], picked: [4, 1]);

      board.delete();
      expect(board.picked, [4]);

      board
        ..delete()
        ..delete();
      expect(board.picked, isEmpty);
    });

    test('a tile can only be in the entry once', () {
      final board = Board(letters: [...letters])
        ..pick(2)
        ..pick(2);

      expect(board.picked, [2]);
    });
  });

  group('UT-5: banner selection', () {
    List<String> titles(
      BannerTracker tracker,
      int found, {
      String word = 'loam',
    }) => tracker
        .onWordFound(found: found, total: 20, word: word)
        .map((banner) => banner.title)
        .toList();

    test('each threshold shows its banner at the exact boundary', () {
      final tracker = BannerTracker();

      expect(titles(tracker, 6), isEmpty);
      expect(titles(tracker, 7), ['Good start!']);
      expect(titles(tracker, 13), isEmpty);
      expect(titles(tracker, 14), ['Great going!']);
      expect(titles(tracker, 19), isEmpty);
      expect(titles(tracker, 20), ['Puzzle complete!']);
    });

    test('a jump past two thresholds shows only the highest', () {
      final tracker = BannerTracker();

      expect(titles(tracker, 14), ['Great going!']);
      expect(titles(tracker, 15), isEmpty);
    });

    test('the nine-letter banner comes first, with the word', () {
      final tracker = BannerTracker();

      final banners = tracker.onWordFound(
        found: 7,
        total: 20,
        word: 'nominally',
      );

      expect(banners.map((banner) => banner.title), [
        'You found the nine-letter word!',
        'Good start!',
      ]);
      expect(banners.first.text, 'NOMINALLY uses every tile.');
    });

    test('no banner repeats in a puzzle', () {
      final tracker = BannerTracker();
      tracker.onWordFound(found: 7, total: 20, word: 'nominally');

      expect(titles(tracker, 8, word: 'nominally'), isEmpty);
    });

    test('a restored game does not show a banner again', () {
      final first = BannerTracker();
      first.onWordFound(found: 7, total: 20, word: 'loam');

      final restored = BannerTracker(shown: first.shown);

      expect(titles(restored, 8), isEmpty);
    });
  });
}
