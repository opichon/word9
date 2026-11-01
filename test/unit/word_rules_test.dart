import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:word9/game/word_lists.dart';
import 'package:word9/game/word_tally.dart';
import 'package:word9/game/word_validation.dart';

/// The test puzzle, `nominally` with centre `l`, the outer L at position 7.
const letters = ['n', 'o', 'm', 'i', 'l', 'n', 'a', 'l', 'y'];

/// The test puzzle's 22 answers.
const solutions = [
  'alimony', 'alloy', 'ally', 'inlay', 'lain', 'lily', 'lion', 'loam', 'loan',
  'loin', 'loyal', 'mail', 'mainly', 'mall', 'manly', 'mill', 'nail',
  'nominal', 'nominally', 'nylon', 'oily', 'only', //
];

void main() {
  final fixture = jsonDecode(
    File('test/fixtures/word_data.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final lists = WordLists.fromJson(fixture);

  group('UT-1: word validation', () {
    final tally = WordTally(solutions: solutions, found: ['loam']);

    String? check(List<int> picked) => validateEntry(
      letters: letters,
      lists: lists,
      picked: picked,
      tally: tally,
    )?.message('en-GB');

    test('too short comes before a missing centre tile', () {
      expect(check([1, 3, 7]), 'Too short: use at least 4 letters');
    });

    test('a word without the centre letter is rejected', () {
      expect(check([2, 6, 3, 0]), 'Must include the centre letter L');
    });

    test('an outer tile with the centre letter is rejected', () {
      expect(check([2, 6, 3, 7]), 'Must include the centre letter L');
    });

    test('a word already found is rejected', () {
      expect(check([4, 1, 6, 2]), 'Already found');
    });

    test('a word outside the lists is rejected', () {
      expect(check([4, 2, 0, 1]), '“LMNO” isn\'t in the word list');
    });

    test('a new word using the centre tile is valid', () {
      expect(check([2, 6, 3, 4]), isNull);
    });

    test('en-US spells center its way', () {
      expect(
        const MissingCentre('l').message('en-US'),
        'Must include the center letter L',
      );
    });

    test('the accepted messages match Nine Tile', () {
      expect(acceptedMessage('loam'), '+ LOAM');
      expect(acceptedMessage('nominally'), 'Nine-letter word! NOMINALLY');
    });
  });

  test('UT-6: found words are sorted and counted', () {
    final tally = WordTally(solutions: solutions)
      ..add('nail')
      ..add('loam')
      ..add('alloy');

    expect(tally.foundWords, ['alloy', 'loam', 'nail']);
    expect(tally.foundCount, 3);
  });

  test('UT-7: the dictionary address is the URL plus the encoded word', () {
    expect(
      lists.dictionaryAddress('loam').toString(),
      'https://www.collinsdictionary.com/dictionary/english/loam',
    );
    final us = WordLists.fromJson({
      ...fixture,
      'dict': 'https://www.merriam-webster.com/dictionary/',
      'lang': 'en-US',
    });
    expect(
      us.dictionaryAddress('a b').toString(),
      'https://www.merriam-webster.com/dictionary/a%20b',
    );
  });

  test('UT-8: an accepted word raises the total and stays listed', () {
    final tally = WordTally(solutions: solutions, found: solutions.take(5));

    expect(lists.contains('moil'), isTrue);
    expect(
      validateEntry(
        letters: letters,
        lists: lists,
        picked: [2, 1, 3, 4],
        tally: tally,
      ),
      isNull,
    );
    tally.add('moil');

    expect('${tally.foundCount} of ${tally.total}', '6 of 23');
    expect(tally.allWords, contains('moil'));
  });
}
