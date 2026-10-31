import 'dart:math';

/// A puzzle: a nine-letter word and its centre letter.
class Puzzle {
  const Puzzle({required this.centre, required this.level, required this.seed});

  /// The letter on the centre tile.
  final String centre;

  /// 1 (Easy), 2 (Medium) or 3 (Hard).
  final int level;

  /// The nine-letter word.
  final String seed;
}

/// Every puzzle of one variant, read from the word-data format in
/// `tool/word_data_format.md`.
class PuzzleBook {
  PuzzleBook({required this.puzzles, required this.testPool});

  factory PuzzleBook.fromJson(Map<String, dynamic> json) => PuzzleBook(
    puzzles: (json['p'] as String).split(' ').map((entry) {
      return Puzzle(
        centre: entry[9],
        level: int.parse(entry[10]),
        seed: entry.substring(0, 9),
      );
    }).toList(),
    testPool: (json['d'] as String).split(' ').map((entry) {
      return Puzzle(centre: entry[9], level: 1, seed: entry.substring(0, 9));
    }).toList(),
  );

  final List<Puzzle> puzzles;

  /// The small Easy puzzles of test mode.
  final List<Puzzle> testPool;

  /// Picks a puzzle at random, from the test pool in [testMode] whatever the
  /// [level]. There's no play history, so a puzzle can repeat.
  Puzzle pick({
    required int level,
    required Random random,
    required bool testMode,
  }) {
    final pool = testMode
        ? testPool
        : puzzles.where((puzzle) => puzzle.level == level).toList();
    return pool[random.nextInt(pool.length)];
  }
}
