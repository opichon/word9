#!/usr/bin/env python3
"""Tests for the word-data contract check: python3 -m unittest discover -s tool"""
import json
import os
import unittest

from check_word_data import problems_in

FIXTURE = os.path.join(os.path.dirname(__file__), '..', 'test', 'fixtures', 'word_data.json')


class ContractCheck(unittest.TestCase):
    def setUp(self):
        with open(FIXTURE, encoding='utf-8') as file:
            self.data = json.load(file)

    def assert_rejected(self, text):
        self.assertTrue(any(text in p for p in problems_in(self.data)), problems_in(self.data))

    def test_the_fixture_is_valid(self):
        self.assertEqual(problems_in(self.data), [])

    def test_a_missing_field_is_rejected(self):
        del self.data['x']
        self.assert_rejected('missing fields')

    def test_an_unknown_field_is_rejected(self):
        self.data['extra'] = ''
        self.assert_rejected('unknown fields')

    def test_a_malformed_puzzle_is_rejected(self):
        self.data['p'] += ' nominally'
        self.assert_rejected('malformed puzzle')

    def test_a_level_out_of_range_is_rejected(self):
        self.data['p'] += ' nominallyl4'
        self.assert_rejected('malformed puzzle')

    def test_a_centre_letter_outside_the_word_is_rejected(self):
        self.data['d'] += ' nominallyz'
        self.assert_rejected('centre letter not in word')

    def test_a_malformed_word_is_rejected(self):
        self.data['v'] = 'oil ' + self.data['v']
        self.assert_rejected('malformed word')

    def test_unsorted_words_are_rejected(self):
        self.data['x'] = 'zebra ' + self.data['x']
        self.assert_rejected('x must be sorted')

    def test_a_word_in_both_lists_is_rejected(self):
        self.data['x'] = 'alimony ' + self.data['x']
        self.assert_rejected('words in both v and x')

    def test_an_unknown_variant_is_rejected(self):
        self.data['lang'] = 'en-AU'
        self.assert_rejected('unknown lang')


if __name__ == '__main__':
    unittest.main()
