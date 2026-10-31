/// One variant's words, read from the word-data format in
/// `tool/word_data_format.md`.
class WordLists {
  WordLists({
    required this.answers,
    required Set<String> accepted,
    required this.dictionary,
    required this.lang,
  }) : _accepted = accepted,
       _answerSet = answers.toSet();

  factory WordLists.fromJson(Map<String, dynamic> json) => WordLists(
    accepted: (json['x'] as String).split(' ').toSet(),
    answers: (json['v'] as String).split(' '),
    dictionary: json['dict'] as String,
    lang: json['lang'] as String,
  );

  /// Words that count toward a puzzle's total.
  final List<String> answers;

  /// The dictionary's address, which a URL-encoded word is appended to.
  final String dictionary;

  /// The variant: `en-GB` or `en-US`.
  final String lang;

  final Set<String> _accepted;
  final Set<String> _answerSet;

  /// Whether [word] is a valid entry: an answer or an accepted word.
  bool contains(String word) =>
      _answerSet.contains(word) || _accepted.contains(word);

  /// The dictionary page for [word].
  Uri dictionaryAddress(String word) =>
      Uri.parse(dictionary + Uri.encodeComponent(word));
}
