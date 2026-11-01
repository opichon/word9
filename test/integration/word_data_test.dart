import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final digests = jsonDecode(
    File('test/fixtures/word_data_digests.json').readAsStringSync(),
  ) as Map<String, dynamic>;

  const variants = {
    'en-GB': (
      answers: 29223,
      accepted: 40941,
      dictionary: 'https://www.collinsdictionary.com/dictionary/english/',
    ),
    'en-US': (
      answers: 29270,
      accepted: 41000,
      dictionary: 'https://www.merriam-webster.com/dictionary/',
    ),
  };

  for (final MapEntry(key: lang, value: expected) in variants.entries) {
    group('IT-2: packaged word data, $lang', () {
      late Map<String, dynamic> data;
      setUpAll(() async {
        data = jsonDecode(
          await rootBundle.loadString('assets/words/$lang.json'),
        ) as Map<String, dynamic>;
      });

      int count(String field) => (data[field] as String).split(' ').length;

      test('counts match the spec', () {
        expect(count('v'), expected.answers);
        expect(count('x'), expected.accepted);
        expect(count('p'), 7500);
        expect(count('d'), 25);
      });

      test('each level has 2,500 puzzles', () {
        final puzzles = (data['p'] as String).split(' ');
        for (final level in ['1', '2', '3']) {
          expect(puzzles.where((p) => p.endsWith(level)).length, 2500);
        }
      });

      test('names the variant and its dictionary', () {
        expect(data['lang'], lang);
        expect(data['dict'], expected.dictionary);
      });

      test('matches the digest from Nine Tile', () {
        final canonical = jsonEncode(SplayTreeMap<String, dynamic>.of(data));
        expect(
          sha256.convert(utf8.encode(canonical)).toString(),
          digests[lang],
        );
      });
    });
  }
}
