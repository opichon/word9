# Word-data format

The contract between the word-data build tool and the game rules. There is one UTF-8 JSON file per variant, holding one object with these fields, as in Nine Tile's `DATA`:

| Field | Type | Content |
| --- | --- | --- |
| `d` | string | Test-mode puzzles, separated by spaces. Each is a nine-letter word followed by its centre letter, e.g. `inventingv`. |
| `dict` | string | Dictionary address: an `https://` URL that a URL-encoded word is appended to. |
| `lang` | string | Variant: `en-GB` or `en-US`. |
| `p` | string | Puzzles, separated by spaces. Each is a nine-letter word, its centre letter and its level (`1` to `3`), e.g. `nominallyl1`. |
| `v` | string | Answers: words that count toward a puzzle's total, sorted and separated by spaces. |
| `x` | string | Accepted words: valid if entered, but not counted until found, sorted and separated by spaces. No word is in both `v` and `x`. |

Words are lowercase `a` to `z`. Answers and accepted words have 4 to 9 letters. A puzzle's centre letter is one of its word's letters.

`python3 tool/check_word_data.py <file>...` checks files against this contract. `test/fixtures/word_data.json` is a small valid file that consumers can develop against.
