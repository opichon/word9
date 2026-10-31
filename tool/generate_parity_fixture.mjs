#!/usr/bin/env node
// Writes test/fixtures/solve_parity.json from Nine Tile's own JavaScript `solve`, at commit 3543b45.
//
// Usage: node tool/generate_parity_fixture.mjs <path to a ninetile checkout>
//
// This ran once, and its output is committed. Tests read that file and need neither this script nor ninetile.
// Sample: all 25 test-mode puzzles and the first 10 puzzles of each level, for each variant.
import { execFileSync } from 'node:child_process';
import { writeFileSync } from 'node:fs';
import vm from 'node:vm';

const COMMIT = '3543b45';
const repo = process.argv[2];
if (!repo) throw new Error('give the path to a ninetile checkout');

function solverFor(page) {
  const html = execFileSync('git', ['-C', repo, 'show', `${COMMIT}:${page}`], {
    encoding: 'utf8',
    maxBuffer: 1 << 24,
  });
  const piece = (pattern) => {
    const match = html.match(pattern);
    if (!match) throw new Error(`not found in ${page}: ${pattern}`);
    return match[0];
  };
  const source = [
    piece(/const DATA = \{.*\};/),
    piece(/const DICT = .*;/),
    piece(/const counts = .*;/),
    piece(/function fits\(.*/),
    piece(/function solve\(.*/),
    'this.result = { DATA, solve };',
  ].join('\n');
  const context = {};
  vm.runInNewContext(source, context);
  return context.result;
}

const fixture = {};
for (const [lang, page] of [['en-GB', 'src/index.html'], ['en-US', 'src/en-us/index.html']]) {
  const { DATA, solve } = solverFor(page);
  const sample = [
    ...DATA.d.split(' '),
    ...['1', '2', '3'].flatMap((level) =>
      DATA.p.split(' ').filter((entry) => entry[10] === level).slice(0, 10)),
  ];
  fixture[lang] = sample.map((entry) => {
    const seed = entry.slice(0, 9);
    const centre = entry[9];
    return { centre, seed, solutions: [...solve(seed.split(''), centre)] };
  });
}
writeFileSync('test/fixtures/solve_parity.json', `${JSON.stringify(fixture)}\n`);
