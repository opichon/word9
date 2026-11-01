import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:word9/game/word_lists.dart';

Map<String, dynamic> readJson(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

void main() {
  final fixture = readJson('test/fixtures/solve_parity.json');

  for (final MapEntry(key: lang, value: sample) in fixture.entries) {
    test('UT-2: solving matches Nine Tile on real data, $lang', () {
      final lists = WordLists.fromJson(readJson('assets/words/$lang.json'));
      final puzzles = sample as List<dynamic>;

      expect(puzzles.length, 55);
      for (final puzzle in puzzles.cast<Map<String, dynamic>>()) {
        final seed = puzzle['seed'] as String;
        expect(
          lists.solve(seed.split(''), puzzle['centre'] as String),
          puzzle['solutions'],
          reason: seed,
        );
      }
    });
  }
}
