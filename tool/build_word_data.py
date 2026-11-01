#!/usr/bin/env python3
"""Build word9's word data from SCOWL and write it to assets/words/.

Usage:
  curl -L -o scowl.tar.gz https://downloads.sourceforge.net/wordlist/scowl-2020.12.07.tar.gz
  tar xzf scowl.tar.gz
  python3 tool/build_word_data.py --scowl scowl-2020.12.07

The rules are adapted from Nine Tile's tools/build_words.py at commit 3543b45. word9 keeps its own copy, so the
two apps can change independently; see specs/adr/adr-word-data-pipeline.md. tool/word_data_format.md describes
the output.

Word sources (SCOWL, http://wordlist.aspell.net, Copyright 2000-2018 Kevin Atkinson; see SCOWL_NOTICE):
  answers  (v)  common words, SCOWL level <= 35, in the variant's spelling
  accepted (x)  valid if entered but not counted in a puzzle's total: rarer words (levels 40-70), alternative
                spellings, capitalised non-name words (Latin, Monday) and strong swear words
  never         proper names (London, Abigail), the other variant's spellings, racial slurs
Puzzles (p) are "<nine-letter word><centre letter><level>"; d is the short test-mode pool.
"""
import argparse
import collections
import hashlib
import json
import os
import re

VARIANTS = {
    'en-GB': {'words': ['english-words', 'british-words'], 'alt': ['british_variant_1-words'],
              'upper': ['english-upper', 'british-upper'],
              'dict': 'https://www.collinsdictionary.com/dictionary/english/'},
    'en-US': {'words': ['english-words', 'american-words'], 'alt': ['variant_1-words'],
              'upper': ['english-upper', 'american-upper'],
              'dict': 'https://www.merriam-webster.com/dictionary/',
              # spellings some Americans use that SCOWL files under other variants: accepted, never counted
              'accept': ['grey', 'greyed', 'greyer', 'greyest', 'greying', 'greyish', 'greyness', 'greys',
                         'judgement']},
}
ANSWER_LEVEL, ACCEPT_LEVEL, COMMON_LEVEL = 35, 70, 20
PER_LEVEL, DEV_COUNT = 2500, 25
# (min answers, max answers, min share of very common answers, max share, max level of the nine-letter word)
LEVELS = {1: (15, 30, 0.00, 1.00, 20), 2: (31, 50, 0.00, 1.00, 35), 3: (51, 80, 0.00, 1.00, 35)}
DEV = (6, 14, 0.50, 1.00, 20)

SCOWL_NOTICE = """Word list derived from SCOWL (http://wordlist.aspell.net), Copyright 2000-2018 by Kevin Atkinson.
Permission to use, copy, modify, distribute and sell these word lists, the associated scripts, the output
created from the scripts, and its documentation for any purpose is hereby granted without fee, provided that
the above copyright notice appears in all copies and that both that copyright notice and this permission
notice appear in supporting documentation. Kevin Atkinson makes no representations about the suitability
of this array for any purpose. It is provided "as is" without express or implied warranty."""

WORD = re.compile(r'^[a-z]{4,9}$')
ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')


def read_lists(final, cats, max_level, lower=False):
    """{word: lowest SCOWL level} for the given categories."""
    out = {}
    for f in os.listdir(final):
        cat, _, lvl = f.rpartition('.')
        if cat not in cats or int(lvl) > max_level:
            continue
        for line in open(os.path.join(final, f), encoding='latin-1'):
            w = line.strip()
            if lower and w[:1].isupper() and w[1:].islower():
                w = w.lower()
            if WORD.match(w):
                out[w] = min(out.get(w, 99), int(lvl))
    return out


def read_misc(scowl, *names):
    return {l.strip() for n in names for l in open(os.path.join(scowl, 'misc', n), encoding='latin-1') if l.strip()}


def build(scowl, variant):
    cfg, final = VARIANTS[variant], os.path.join(scowl, 'final')
    slurs, swears = read_misc(scowl, 'offensive.1', 'offensive.2'), read_misc(scowl, 'profane.1')
    words = read_lists(final, cfg['words'], ACCEPT_LEVEL)
    answers = {w: l for w, l in words.items() if l <= ANSWER_LEVEL and w not in slurs and w not in swears}
    extra = set(words) | set(read_lists(final, cfg['alt'], ACCEPT_LEVEL)) \
        | set(read_lists(final, cfg['upper'], ANSWER_LEVEL, lower=True)) | set(cfg.get('accept', []))
    extra = sorted(extra - set(answers) - slurs)

    # every (nine-letter word, centre letter) pair, with its answer count and share of very common answers
    counted = [(w, collections.Counter(w)) for w in answers]
    candidates = []
    for seed in sorted(w for w, l in answers.items() if len(w) == 9 and l <= ANSWER_LEVEL):
        pool = collections.Counter(seed)
        fit = [w for w, c in counted if all(pool[k] >= n for k, n in c.items())]
        for a in sorted(set(seed)):
            sol = [w for w in fit if a in w]
            candidates.append((seed, a, len(sol), sum(answers[w] <= COMMON_LEVEL for w in sol) / len(sol)))

    def pick(rule, taken, limit):
        lo, hi, flo, fhi, seed_max = rule
        ok = [c for c in candidates if lo <= c[2] <= hi and flo <= c[3] <= fhi
              and answers[c[0]] <= seed_max and c[:2] not in taken]
        ok.sort(key=lambda c: hashlib.sha1((c[0] + c[1]).encode()).hexdigest())  # stable shuffle
        return ok[:limit]

    puzzles, taken = [], set()
    for level, rule in LEVELS.items():
        chosen = pick(rule, taken, PER_LEVEL)
        taken |= {c[:2] for c in chosen}
        puzzles += [c[0] + c[1] + str(level) for c in chosen]
        print(f'{variant} level {level}: {len(chosen)} puzzles, avg {sum(c[2] for c in chosen) / len(chosen):.1f} answers')
    dev = [c[0] + c[1] for c in pick(DEV, set(), DEV_COUNT)]
    print(f'{variant} answers {len(answers)}, accepted {len(extra)}, test-mode puzzles {len(dev)}')
    return {'d': ' '.join(dev), 'dict': cfg['dict'], 'lang': variant, 'p': ' '.join(puzzles),
            'v': ' '.join(sorted(answers)), 'x': ' '.join(extra)}


def main():
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    ap.add_argument('--out', default=os.path.join(ROOT, 'assets', 'words'), help='output folder')
    ap.add_argument('--scowl', required=True, help='unpacked SCOWL release folder')
    args = ap.parse_args()
    os.makedirs(args.out, exist_ok=True)
    for variant in sorted(VARIANTS):
        path = os.path.join(args.out, variant + '.json')
        with open(path, 'w', encoding='utf-8', newline='\n') as file:
            json.dump(build(args.scowl, variant), file, separators=(',', ':'), sort_keys=True)
        print('wrote', os.path.relpath(path, ROOT))


if __name__ == '__main__':
    main()
