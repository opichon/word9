/// The words of a puzzle: those found so far, and the total to find.
class WordTally {
  WordTally({
    required Iterable<String> solutions,
    Iterable<String> found = const [],
  }) : _found = [...found],
       _solutions = {...solutions, ...found}.toList()..sort();

  final List<String> _found;
  final List<String> _solutions;

  /// Every word of the puzzle, sorted. An accepted word joins it once found.
  List<String> get allWords => List.unmodifiable(_solutions);

  /// How many words have been found.
  int get foundCount => _found.length;

  /// The words found, sorted.
  List<String> get foundWords => List.unmodifiable([..._found]..sort());

  /// How many words the puzzle has, including accepted words found so far.
  int get total => _solutions.length;

  /// Whether [word] has already been found.
  bool hasFound(String word) => _found.contains(word);

  /// Records [word] as found.
  void add(String word) {
    _found.add(word);
    if (!_solutions.contains(word)) {
      _solutions
        ..add(word)
        ..sort();
    }
  }
}
