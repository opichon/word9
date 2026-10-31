import 'word_lists.dart';
import 'word_tally.dart';

/// The centre tile's position in the 3×3 grid.
const centreIndex = 4;

/// The fewest letters a word can have.
const minimumLength = 4;

/// Why an entry was rejected.
sealed class Rejection {
  const Rejection();

  /// The message shown to the player, in the [lang] variant's spelling.
  String message(String lang);
}

class TooShort extends Rejection {
  const TooShort();

  @override
  String message(String lang) => 'Too short: use at least 4 letters';
}

class MissingCentre extends Rejection {
  const MissingCentre(this.letter);

  final String letter;

  @override
  String message(String lang) =>
      'Must include the ${lang == 'en-US' ? 'center' : 'centre'} letter '
      '${letter.toUpperCase()}';
}

class AlreadyFound extends Rejection {
  const AlreadyFound();

  @override
  String message(String lang) => 'Already found';
}

class NotInWordList extends Rejection {
  const NotInWordList(this.word);

  final String word;

  @override
  String message(String lang) =>
      '“${word.toUpperCase()}” isn\'t in the word list';
}

/// The word made by the tiles at [picked] on a grid of [letters].
String entryWord(List<String> letters, List<int> picked) =>
    picked.map((index) => letters[index]).join();

/// Checks the entry made by the tiles at [picked], in the spec's order.
///
/// Returns why it's rejected, or null when it's a new, valid word. The centre
/// check looks at the tile, not the letter, so an outer tile with the centre's
/// letter doesn't count.
Rejection? validateEntry({
  required List<String> letters,
  required WordLists lists,
  required List<int> picked,
  required WordTally tally,
}) {
  final word = entryWord(letters, picked);
  if (word.length < minimumLength) return const TooShort();
  if (!picked.contains(centreIndex)) return MissingCentre(letters[centreIndex]);
  if (tally.hasFound(word)) return const AlreadyFound();
  if (!lists.contains(word)) return NotInWordList(word);
  return null;
}

/// The message shown when [word] is accepted.
String acceptedMessage(String word) => word.length == 9
    ? 'Nine-letter word! ${word.toUpperCase()}'
    : '+ ${word.toUpperCase()}';
