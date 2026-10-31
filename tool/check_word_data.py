#!/usr/bin/env python3
"""Check word-data files against the contract in tool/word_data_format.md."""
import json
import re
import sys

FIELDS = {'d', 'dict', 'lang', 'p', 'v', 'x'}
LANGS = {'en-GB', 'en-US'}
WORD = re.compile(r'^[a-z]{4,9}$')
PUZZLE = re.compile(r'^([a-z]{9})([a-z])([123])$')
TEST_PUZZLE = re.compile(r'^([a-z]{9})([a-z])$')


def problems_in(data):
    """Return every way the decoded data breaks the contract."""
    if not isinstance(data, dict):
        return ['the file must hold one object']
    found = []
    missing, extra = FIELDS - set(data), set(data) - FIELDS
    if missing:
        found.append(f'missing fields: {sorted(missing)}')
    if extra:
        found.append(f'unknown fields: {sorted(extra)}')
    if missing or extra:
        return found
    for field in sorted(FIELDS):
        if not isinstance(data[field], str):
            found.append(f'{field} must be a string')
    if found:
        return found

    if data['lang'] not in LANGS:
        found.append(f'unknown lang: {data["lang"]}')
    if not data['dict'].startswith('https://'):
        found.append(f'dict must be an https URL: {data["dict"]}')

    for field in ('v', 'x'):
        words = data[field].split(' ')
        found += [f'{field}: malformed word: {w!r}' for w in words if not WORD.match(w)]
        if words != sorted(words):
            found.append(f'{field} must be sorted')
    both = set(data['v'].split(' ')) & set(data['x'].split(' '))
    if both:
        found.append(f'words in both v and x: {sorted(both)[:5]}')

    for field, pattern in (('p', PUZZLE), ('d', TEST_PUZZLE)):
        for entry in data[field].split(' '):
            match = pattern.match(entry)
            if not match:
                found.append(f'{field}: malformed puzzle: {entry!r}')
            elif match.group(2) not in match.group(1):
                found.append(f'{field}: centre letter not in word: {entry!r}')
    return found


def main(paths):
    failed = False
    for path in paths:
        with open(path, encoding='utf-8') as file:
            problems = problems_in(json.load(file))
        for problem in problems:
            print(f'{path}: {problem}')
        failed = failed or bool(problems)
    return 1 if failed else 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
