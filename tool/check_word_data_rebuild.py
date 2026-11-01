#!/usr/bin/env python3
"""IT-1, on demand: rebuild the word data from SCOWL and compare it with the digests from Nine Tile.

Usage: python3 tool/check_word_data_rebuild.py [--archive scowl-2020.12.07.tar.gz]

Downloads SCOWL 2020.12.07 when no archive is given. Exits with 0 only when the archive and both variants match.
"""
import argparse
import hashlib
import json
import os
import subprocess
import sys
import tarfile
import tempfile
import urllib.request

SCOWL_URL = 'https://downloads.sourceforge.net/wordlist/scowl-2020.12.07.tar.gz'
SCOWL_SHA256 = '5587667caa20c4891390c2d42dbb4d5c4c3f41bee77af1457ece3ba23fb859cc'
HERE = os.path.dirname(os.path.abspath(__file__))
DIGESTS = os.path.join(HERE, '..', 'test', 'fixtures', 'word_data_digests.json')


def digest(path):
    """SHA-256 of the sorted-key, no-whitespace JSON, as defined in the test plan."""
    with open(path, encoding='utf-8') as file:
        canonical = json.dumps(json.load(file), sort_keys=True, separators=(',', ':')).encode()
    return hashlib.sha256(canonical).hexdigest()


def main():
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    ap.add_argument('--archive', help='a local copy of the SCOWL archive')
    args = ap.parse_args()
    with open(DIGESTS, encoding='utf-8') as file:
        expected = json.load(file)

    with tempfile.TemporaryDirectory() as temp:
        archive = args.archive or os.path.join(temp, 'scowl.tar.gz')
        if not args.archive:
            urllib.request.urlretrieve(SCOWL_URL, archive)
        with open(archive, 'rb') as file:
            actual = hashlib.sha256(file.read()).hexdigest()
        if actual != SCOWL_SHA256:
            print(f'unexpected SCOWL archive: {actual}')
            return 1
        with tarfile.open(archive) as tar:
            tar.extractall(temp, filter='data')
        out = os.path.join(temp, 'out')
        subprocess.run([sys.executable, os.path.join(HERE, 'build_word_data.py'), '--out', out,
                        '--scowl', os.path.join(temp, 'scowl-2020.12.07')], check=True)
        failed = False
        for variant, want in sorted(expected.items()):
            got = digest(os.path.join(out, variant + '.json'))
            print(f'{variant}: {"match" if got == want else "DIFFERENT " + got}')
            failed = failed or got != want
    return 1 if failed else 0


if __name__ == '__main__':
    sys.exit(main())
