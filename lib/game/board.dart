import 'dart:math';

import 'puzzles.dart';

const _centreIndex = 4;

/// The 3×3 grid and the tiles currently in the entry.
class Board {
  Board({required this.letters, Iterable<int> picked = const []})
    : _picked = [...picked];

  /// A new grid for [puzzle]: the centre letter in the middle, and the other
  /// letters shuffled around it.
  factory Board.deal(Puzzle puzzle, Random random) {
    final outer = puzzle.seed.split('')..remove(puzzle.centre);
    return Board(letters: _arrange(outer, puzzle.centre, random));
  }

  /// The nine letters, row by row.
  List<String> letters;

  final List<int> _picked;

  /// The positions of the tiles in the entry, in the order they were tapped.
  List<int> get picked => List.unmodifiable(_picked);

  /// Adds the tile at [index] to the entry, unless it's already there.
  void pick(int index) {
    if (!_picked.contains(index)) _picked.add(index);
  }

  /// Removes the last tile from the entry, if any.
  void delete() {
    if (_picked.isNotEmpty) _picked.removeLast();
  }

  /// Empties the entry.
  void clearEntry() => _picked.clear();

  /// Rearranges the outer tiles and empties the entry.
  void shuffle(Random random) {
    final outer = [...letters]..removeAt(_centreIndex);
    letters = _arrange(outer, letters[_centreIndex], random);
    _picked.clear();
  }

  static List<String> _arrange(
    List<String> outer,
    String centre,
    Random random,
  ) {
    outer.shuffle(random);
    return [...outer.take(_centreIndex), centre, ...outer.skip(_centreIndex)];
  }
}
