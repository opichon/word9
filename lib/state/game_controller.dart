import 'dart:math';

import 'package:flutter/foundation.dart';

import '../game/board.dart';
import '../game/word_tally.dart';
import '../game/word_validation.dart';
import 'word_data.dart';

/// Whether a message reports a success or a failure.
enum MessageKind { bad, good }

/// A message shown under the entry.
class GameMessage {
  const GameMessage(this.text, this.kind);

  final MessageKind kind;
  final String text;
}

/// The state of the game in progress.
class GameController extends ChangeNotifier {
  GameController({required this.lang, required this._random});

  /// The variant: `en-GB` or `en-US`.
  final String lang;

  final Random _random;

  late WordData _data;
  Board? _board;
  bool _disposed = false;
  GameMessage? _message;
  int _shakes = 0;
  late WordTally _tally;

  /// The grid, or null until the word data is loaded.
  Board? get board => _board;

  /// The message to show, if any.
  GameMessage? get message => _message;

  /// How many times the entry has been rejected. Each rise shakes the entry.
  int get shakes => _shakes;

  /// The words of the current puzzle.
  WordTally get tally => _tally;

  /// Loads the word data and starts a puzzle.
  Future<void> load() async {
    final data = await loadWordData(lang);
    if (!_disposed) start(data);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// Starts a puzzle from [data].
  void start(WordData data) {
    _data = data;
    final puzzle = data.book.pick(level: 1, random: _random, testMode: false);
    final board = Board.deal(puzzle, _random);
    _board = board;
    _tally = WordTally(
      solutions: data.lists.solve(board.letters, puzzle.centre),
    );
    _message = null;
    notifyListeners();
  }

  /// Adds the tile at [index] to the entry.
  void tapTile(int index) {
    final board = _board;
    if (board == null || board.picked.contains(index)) return;
    board.pick(index);
    _message = null;
    notifyListeners();
  }

  /// Removes the last letter from the entry.
  void delete() {
    final board = _board;
    if (board == null || board.picked.isEmpty) return;
    board.delete();
    notifyListeners();
  }

  /// Rearranges the outer tiles and empties the entry.
  void shuffle() {
    _board?.shuffle(_random);
    notifyListeners();
  }

  /// Submits the entry.
  void submit() {
    final board = _board;
    if (board == null || board.picked.isEmpty) return;
    final rejection = validateEntry(
      letters: board.letters,
      lists: _data.lists,
      picked: board.picked,
      tally: _tally,
    );
    if (rejection != null) {
      _message = GameMessage(rejection.message(lang), MessageKind.bad);
      _shakes++;
    } else {
      final word = entryWord(board.letters, board.picked);
      _tally.add(word);
      _message = GameMessage(acceptedMessage(word), MessageKind.good);
    }
    board.clearEntry();
    notifyListeners();
  }
}
