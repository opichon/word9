import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../game/puzzles.dart';
import '../game/word_lists.dart';

/// One variant's words and puzzles.
class WordData {
  const WordData({required this.book, required this.lists});

  factory WordData.fromJson(Map<String, dynamic> json) => WordData(
    book: PuzzleBook.fromJson(json),
    lists: WordLists.fromJson(json),
  );

  final PuzzleBook book;
  final WordLists lists;
}

WordData _decode(String source) =>
    WordData.fromJson(jsonDecode(source) as Map<String, dynamic>);

/// Loads the [lang] variant's asset, decoding it off the UI thread.
Future<WordData> loadWordData(String lang) async {
  final source = await rootBundle.loadString('assets/words/$lang.json');
  return compute(_decode, source);
}
