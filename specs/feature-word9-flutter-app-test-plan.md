---
description: "Test plan for word9: offline Flutter app with the same features as Nine Tile"
generated:
  at: 2026-11-01T00:46:15+07:00
  by: claude-code/2.1.316
id: feature-word9-flutter-app-test-plan
links:
  - note: The spec this plan tests
    rel: references
    to: feature-word9-flutter-app
sources:
  - id: ninetile-gb
    resource: https://github.com/opichon/ninetile/blob/3543b45/src/index.html
    title: Nine Tile web app, en-GB variant
  - id: ninetile-us
    resource: https://github.com/opichon/ninetile/blob/3543b45/src/en-us/index.html
    title: Nine Tile web app, en-US variant
status: stable
tags:
  - android
  - flutter
  - ios
  - tests
  - word9
title: "Test plan: word9: offline Flutter app with the same features as Nine Tile"
type: Test plan
---

# Test plan: word9: offline Flutter app with the same features as Nine Tile

## 1. Scope

- **Spec:** [word9: offline Flutter app with the same features as Nine Tile](/feature-word9-flutter-app.md)
- **Spec type:** Feature
- **Proves:** word9 matches Nine Tile[^ninetile-gb][^ninetile-us] at commit `3543b45` in rules, text and word data on Android and iOS, works offline with no accounts, and handles the spec's edge cases.
- **Codebase scope:**
  - `opichon/ninetile` @ `main` (`3543b45`): read-only reference for expected values; no test depends on it at run time.
  - `opichon/word9` @ `main` (`5ebc4a1`): no app code yet. Test locations and subjects are planned. Subjects are named by role, and the implementation plan maps them to code.

## 2. Strategy

| Level | Tool | Location | Runs for real | Test doubles |
| ----- | ---- | -------- | ------------- | ------------ |
| Acceptance (automated) | Flutter `integration_test` on an Android emulator and an iOS simulator | `word9/integration_test/` | App, word data, storage | Random source (fixed puzzle); URL launcher (records the URL) |
| Acceptance (`@manual`) | Release checklist, followed by a person | `word9/docs/release-checklist.md` (new) | Everything, on an installed build, including the OS and browser | None |
| Non-functional | `flutter_test` for accessibility; build check for the Android permission; manual for performance and packet capture | `word9/test/`, release checklist | As per each row | As per each row |
| Integration | `flutter_test` | `word9/test/integration/` | Game rules with real storage and word data | Random source where stated |
| Component | `flutter_test` widget tests | `word9/test/widgets/` | One widget tree | Game state, clock, storage and URL launcher where stated |
| Unit | `flutter_test` | `word9/test/unit/` | Game rules | Random source where stated |

CI runs the automated levels with neither SCOWL nor the ninetile repository available. Parity comes from stored digests and a static fixture (section 10). Rebuilding from SCOWL (IT-1) runs on demand.

**Levels not used:** Regression: new system, no existing suites.

## 3. Coverage

Spec items are referenced in document order: `US-n/AC-m` for acceptance criteria, `EC-n` for edge cases (section 7), `R-n` for rollout exit criteria (section 9), and `B-n` for the deliberate differences (section 6). `C-n` numbers each constraint bullet in section 5:

C-1 Flutter on Android and iOS; C-2 minimum OS; C-3 portrait lock; C-4 centred width and scrolling; C-5 airplane mode; C-6 no network requests; C-7 no account; C-8 no analytics, ads, crash reporting or purchases; C-9 parity of rules, text and validation; C-10 text and spelling; C-11 validation order; C-12a accepted word raises total; C-12b puzzle can repeat; C-12c Shuffle and Delete after reveal; C-13 level labels; C-14 progress; C-15 banners once; C-16 highest banner, nine-letter first; C-17 banner timing; C-18 palettes; C-19 fonts and layout; C-20 reduced motion; C-21 screen reader; C-22 own word data; C-23 exact data match; C-24 Licences; C-25 settings entry point; C-26 variant labels; C-27 new-text spelling; C-28 Privacy policy entry; C-29 test mode whole-app; C-30 level per variant; C-31 saved game per variant; C-32 published policy; C-33 store privacy forms; C-34 review notes; C-35 icon and store materials; C-36 cold start; C-37 new puzzle or variant switch; C-38 tap or submit.

| Spec item | Summary | Tests | Status |
| --------- | ------- | ----- | ------ |
| US-1/AC-1 | Tap adds letter, tile used | AT-1 | Covered |
| US-1/AC-2 | Delete frees tile | AT-1 | Covered |
| US-1/AC-3 | Valid word found | AT-1 | Covered |
| US-1/AC-4 | Invalid entry | AT-2, UT-1 | Covered |
| US-1/AC-5 | Shuffle | UT-4 | Covered |
| US-2/AC-1 | Picker with current level | AT-3 | Covered |
| US-2/AC-2 | Choose level | AT-3, IT-5 | Covered |
| US-2/AC-3 | Cancel picker | AT-4 | Covered |
| US-3/AC-1 | Count, bar, sorted list | UT-6, CT-3 | Covered |
| US-3/AC-2 | Milestone banner | AT-5, UT-5 | Covered |
| US-3/AC-3 | Nine-letter word | AT-6 | Covered |
| US-3/AC-4 | Dismiss banner | CT-2 | Covered |
| US-4/AC-1 | Reveal question | AT-7 | Covered |
| US-4/AC-2 | Keep playing | AT-7 | Covered |
| US-4/AC-3 | Reveal | AT-8 | Covered |
| US-5/AC-1 | Dictionary opens | AT-9, AT-16, UT-7 | Covered |
| US-5/AC-2 | State kept after return | AT-16 | Covered |
| US-6/AC-1 | Fresh install offline | AT-15 | Covered |
| US-6/AC-2 | Kill and reopen | AT-17, IT-3 | Covered |
| US-7/AC-1 | Default variant | CT-7 | Covered |
| US-7/AC-2 | Choose variant | AT-10, IT-2, IT-6 | Covered |
| US-7/AC-3 | Resume or new on switch | AT-10, IT-5 | Covered |
| US-7/AC-4 | Licences | AT-11 | Covered |
| US-7/AC-5 | Privacy policy opens | AT-12, AT-16 | Covered |
| US-8/AC-1 | Long-press toggle | AT-13, AT-14 | Covered |
| US-8/AC-2 | Test pool and tag | AT-13, UT-3 | Covered |
| US-8/AC-3 | Test mode persists | IT-6 | Covered |
| EC-1 | Killed mid-word | AT-17, IT-3 | Covered |
| EC-2 | Corrupt save | IT-4 | Covered |
| EC-3 | Storage write fails | CT-11 | Covered |
| EC-4 | Dictionary with no connection | AT-16 | Covered |
| EC-5 | Test mode toggled | IT-7 | Covered |
| EC-6 | Variant switch, mode mismatch | IT-7 | Covered |
| EC-7 | Level chosen in test mode | UT-3 | Covered |
| EC-8 | Enter on empty entry | CT-1 | Covered |
| EC-9 | Delete on empty entry | CT-1 | Covered |
| EC-10 | Tile after reveal | AT-8 | Covered |
| EC-11 | Shuffle with letters | UT-4 | Covered |
| EC-12 | Outer tile with centre's letter | UT-1 | Covered |
| EC-13 | Picker dismissed | AT-4 | Covered |
| EC-14 | Android back on picker | AT-4 | Covered |
| EC-15 | Android back elsewhere | AT-18 | Covered |
| EC-16 | Rotation | CT-8 | Covered |
| EC-17 | Privacy policy with no connection | AT-16 | Covered |
| EC-18 | No saved game for variant | IT-5 | Covered |
| EC-19 | First launch locale | CT-7 | Covered |
| B-1 | No keyboard input | CT-9 | Covered |
| B-2 | Language setting | AT-10 | Covered |
| B-3 | Test mode gesture | AT-13 | Covered |
| C-1 | Flutter on Android and iOS | NF-7 | Covered |
| C-2 | Minimum OS | | Not tested |
| C-3 | Portrait lock | AT-18 | Covered |
| C-4 | Centred width, scrolling | CT-8 | Covered |
| C-5 | Airplane mode | AT-15, CT-10 | Covered |
| C-6 | No network requests | NF-4, NF-5 | Covered |
| C-7 | No account | AT-15 | Covered |
| C-8 | No analytics, ads, reporting, purchases | NF-5 | Covered |
| C-9 | Parity of rules and validation | UT-2 | Covered |
| C-10 | Text and spelling | CT-4 | Covered |
| C-11 | Validation order | UT-1 | Covered |
| C-12a | Accepted word raises total | UT-8 | Covered |
| C-12b | Puzzle can repeat | UT-3 | Covered |
| C-12c | Shuffle and Delete after reveal | UT-4 | Covered |
| C-13 | Level labels | CT-4 | Covered |
| C-14 | Progress | CT-3 | Covered |
| C-15 | Banners once per puzzle | UT-5 | Covered |
| C-16 | Highest banner, nine-letter first | UT-5 | Covered |
| C-17 | Banner timing | CT-2 | Covered |
| C-18 | Palettes, system theme | CT-5 | Covered |
| C-19 | Fonts and layout | CT-10 | Covered |
| C-20 | Reduced motion | NF-8 | Covered |
| C-21 | Screen reader | NF-9 | Covered |
| C-22 | Own word data | IT-1 | Covered |
| C-23 | Exact data match | IT-1, IT-2 | Covered |
| C-24 | Licences | AT-11 | Covered |
| C-25 | Settings entry point | AT-10 | Covered |
| C-26 | Variant labels | CT-6 | Covered |
| C-27 | New-text spelling | CT-6 | Covered |
| C-28 | Privacy policy entry | AT-12 | Covered |
| C-29 | Test mode whole-app | IT-7 | Covered |
| C-30 | Level per variant | IT-5 | Covered |
| C-31 | Saved game per variant | IT-5 | Covered |
| C-32 | Published policy | NF-6 | Covered |
| C-33 | Store privacy forms | | Not tested |
| C-34 | Review notes | | Not tested |
| C-35 | Icon, store materials | | Not tested |
| C-36 | Cold start | NF-1 | Blocked |
| C-37 | New puzzle or variant switch | NF-2 | Blocked |
| C-38 | Tap or submit | NF-3 | Blocked |
| R-1 | Diawi install on both platforms | NF-10 | Covered |
| R-2 | Acceptance criteria pass on internal-track builds | AT-1 to AT-18 | Covered |
| R-3 | Closed test and production access | | Not tested |
| R-4 | Live on both stores | | Not tested |

## 4. Acceptance tests

Unless tagged `@manual`, scenarios run on the Android emulator and the iOS simulator. "The test puzzle" is `nominally` with centre `L`, level Easy, en-GB, with 22 answers.

```gherkin
Feature: word9: offline Flutter app with the same features as Nine Tile
  As a Player, I want to play Nine Tile's game on my phone with no connection or account,
  so that I can play anywhere.

  Background:
    Given a fresh install of word9 in English (UK)
    And the test puzzle is in progress

  @AT-1 @US-1/AC-1 @US-1/AC-2 @US-1/AC-3
  Scenario: Build and submit a word by tapping
    When I tap the centre tile, then the tiles for "O", "A", "M", "Y"
    Then the entry shows "LOAMY"
    And the tiles I tapped show as used
    When I tap Delete
    Then the entry shows "LOAM"
    And the last tile I tapped is free again
    When I tap Enter
    Then the message reads "+ LOAM"
    And the words found include "loam"
    And the count reads "1 of 22"

  @AT-2 @US-1/AC-4
  Scenario: An invalid entry is rejected and cleared
    When I enter "LMNO" and tap Enter
    Then the message reads "“LMNO” isn't in the word list"
    And the entry shakes
    And the entry is empty

  @AT-3 @US-2/AC-1 @US-2/AC-2
  Scenario: Choose a level for a new puzzle
    When I tap New puzzle
    Then the picker shows Easy, Medium and Hard with Easy marked
    When I choose Hard
    Then a new Hard puzzle is in progress
    And the message reads "Hard puzzle"
    And the tag reads "Hard puzzle"

  @AT-4 @US-2/AC-3 @EC-13 @EC-14
  Scenario Outline: Dismissing the picker changes nothing
    Given I have found "loam"
    And the picker is open
    When I dismiss it with <action>
    Then the picker closes
    And the test puzzle is still in progress with "loam" found

    Examples:
      | action                       |
      | Cancel                       |
      | a tap outside the picker     |
      | the Android back button      |

  @AT-5 @US-3/AC-2
  Scenario: Reaching 35% shows the encouragement banner once
    Given I have found 7 of the 22 words
    When I find an eighth word
    Then the banner reads "Good start!" and "You have found over a third of the words."
    When I find a ninth word
    Then no banner shows

  @AT-6 @US-3/AC-3
  Scenario: Find the nine-letter word
    When I enter "NOMINALLY" and tap Enter
    Then the message reads "Nine-letter word! NOMINALLY"
    And the banner reads "You found the nine-letter word!" and "NOMINALLY uses every tile."
    And "nominally" is highlighted in the words found

  @AT-7 @US-4/AC-1 @US-4/AC-2
  Scenario: Back out of revealing
    Given I have found "loam"
    When I tap Show all words
    Then I am asked "Reveal and end this puzzle?" with Reveal and Keep playing
    When I tap Keep playing
    Then the puzzle continues with "loam" found

  @AT-8 @US-4/AC-3 @EC-10
  Scenario: Reveal all words
    Given I have found "loam"
    When I tap Show all words and tap Reveal
    Then all 22 words show, with the 21 I missed marked
    And the message reads "The nine-letter word was NOMINALLY"
    And tapping a tile adds nothing to the entry

  @AT-9 @US-5/AC-1
  Scenario Outline: Tapping a word asks for its dictionary page
    Given the variant is <variant>
    And a puzzle is in progress in which I have found "loam"
    When I tap "loam"
    Then the page requested is "<url>"

    Examples:
      | variant      | url                                                        |
      | English (UK) | https://www.collinsdictionary.com/dictionary/english/loam  |
      | English (US) | https://www.merriam-webster.com/dictionary/loam            |

  @AT-10 @US-7/AC-2 @US-7/AC-3 @B-2 @C-25
  Scenario: Switch variant and come back
    Given I have found "loam"
    When I open settings from the header icon and choose English (US)
    Then a new puzzle is in progress
    And the rules read "center letter"
    When I open settings and choose English (UK)
    Then the test puzzle is in progress with "loam" found
    And the rules read "centre letter"

  @AT-11 @US-7/AC-4 @C-24
  Scenario: Read the licences
    When I open settings and open Licences
    Then the SCOWL notice shows
    And the Bricolage Grotesque and Atkinson Hyperlegible notices show

  @AT-12 @US-7/AC-5 @C-28
  Scenario: Open the privacy policy
    When I open settings and tap Privacy policy
    Then the privacy policy page is requested

  @AT-13 @US-8/AC-1 @US-8/AC-2 @B-3
  Scenario: Toggle test mode with the hidden gesture
    When I long-press the word9 title for 3 seconds
    Then a puzzle from the test pool is in progress
    And the tag reads "Easy puzzle · test mode"
    When I long-press the word9 title for 3 seconds
    Then a puzzle outside the test pool is in progress

  @AT-14 @US-8/AC-1
  Scenario: A shorter press doesn't toggle test mode
    When I long-press the word9 title for 2 seconds
    Then the test puzzle is still in progress

  @AT-15 @manual @US-6/AC-1 @C-5 @C-7
  Scenario: First use in airplane mode
    Given a device in airplane mode
    When I install word9 from a release build and open it
    Then a puzzle is playable in the bundled fonts
    And no sign-in is asked for
    And Shuffle, New puzzle, Show all words, settings and Licences all work

  @AT-16 @manual @US-5/AC-1 @US-5/AC-2 @US-7/AC-5 @EC-4 @EC-17
  Scenario Outline: Browser pages online and offline
    Given a release build with a puzzle in progress and "loam" found
    And the device is <connection>
    When I tap <entry>
    Then the browser shows <result>
    When I return to word9
    Then the puzzle is unchanged

    Examples:
      | connection | entry          | result                 |
      | online     | "loam"         | the dictionary page    |
      | offline    | "loam"         | its own error          |
      | online     | Privacy policy | the privacy policy     |
      | offline    | Privacy policy | its own error          |

  @AT-17 @manual @US-6/AC-2 @EC-1
  Scenario: Reopen after the app is killed mid-word
    Given a release build with "loam" found and letters in the entry
    When the app is killed and reopened
    Then "loam" is still found and the tile order is unchanged
    And the entry is empty

  @AT-18 @manual @C-3 @EC-15
  Scenario: Orientation and back on a phone
    Given a release build on an Android phone and an iPhone
    When I rotate the phone
    Then word9 stays in portrait
    When I press the Android back button on the main screen or settings screen
    Then the OS's normal back behaviour applies
```

## 5. Non-functional tests

> **Open question:** Which physical devices run NF-1 to NF-3? The spec names a Pixel 6a and an iPhone 11, and the owner has neither. Blocks NF-1, NF-2 and NF-3. Substitute devices would change the spec.

| ID | Subject | Given | When | Then (threshold) | Test doubles | Covers |
| -- | ------- | ----- | ---- | ---------------- | ------------ | ------ |
| NF-1 | App launch (**Blocked**) | Release build on the agreed devices, process not running | Launch, five runs | Playable grid in at most 3 s on every run | None | C-36 |
| NF-2 | New puzzle and variant switch (**Blocked**) | Release build on the agreed devices | Choose a level; switch variant, five runs each | Done in at most 500 ms on every run | None | C-37 |
| NF-3 | Tile tap and word submission (**Blocked**) | Release build on the agreed devices | Tap a tile; submit a word, five runs each | Shown on screen within 100 ms on every run | None | C-38 |
| NF-4 | Android release build | Release APK built by CI | Read its declared permissions | `INTERNET` isn't declared | None | C-6 |
| NF-5 | Network traffic (manual) | Release builds on iOS and Android, packet capture running, all other apps closed | Play a full session: new puzzle, words, reveal, settings, Licences | No traffic from word9; traffic only starts after tapping a word or Privacy policy | None | C-6, C-8 |
| NF-6 | Published privacy policy (manual) | The GitHub Pages URL, signed out | Open it | It loads with no login and states that no data is collected | None | C-32 |
| NF-7 | Builds | Clean CI checkout with no ninetile repository | Build Android and iOS release | Both builds succeed | None | C-1, C-22 |
| NF-8 | Animations | Widget tree with the reduced-motion setting on | Shake the entry; add a found word; show a banner | No animation runs: the end state appears immediately | Clock | C-20 |
| NF-9 | Screen-reader labels | Board with `nominally`, centre `L` | Read the labels of tiles and controls | Each tile is labelled with its letter; the centre tile with "l, centre letter" (en-GB) or "l, center letter" (en-US); Delete, Shuffle, Enter and New puzzle are labelled | None | C-21 |
| NF-10 | Diawi distribution (manual) | A merge to `main`; an Android phone and a registered iPhone | Install from each Diawi link and open the app | The app installs and opens with a playable puzzle on both phones | None | R-1 |

## 6. Integration tests

| ID | Subject | Given | When | Then | Test doubles | Covers |
| -- | ------- | ----- | ---- | ---- | ------------ | ------ |
| IT-1 | Word-data build (on demand) | SCOWL 2020.12.07, archive SHA-256 as in section 10; no ninetile repository | Build both variants | Digests match section 10 | None | C-22, C-23 |
| IT-2 | Packaged word data | Each variant's assets | Load and count them; compute the digest | Counts match the spec's table (en-GB 29,223 / 40,941 / 7,500 / 25; en-US 29,270 / 41,000 / 7,500 / 25); dictionary URL matches; digests match section 10 | None | C-23, US-7/AC-2 |
| IT-3 | Saved game with real storage | Words found, banners shown, tiles shuffled, letters in the entry, a message showing | Rebuild the app state from storage, for a playing and a revealed puzzle | Found words, revealed state, tile order, level and banners shown are restored; the entry and message are empty | None | US-6/AC-2, EC-1 |
| IT-4 | Saved game with real storage | Each of: unparseable data; a game with other than 9 letters; no saved level | Start the app | New puzzle with no error: at the saved level, or Easy with no saved level | Random source | EC-2 |
| IT-5 | Per-variant storage | en-GB game at Hard; en-US with no game | Choose a level in each; switch back and forth | Each variant keeps its own game and level; en-US starts a new puzzle at its last level, or Easy with none | Random source | C-30, C-31, EC-18, US-7/AC-3, US-2/AC-2 |
| IT-6 | Settings persistence | Variant English (US); test mode on | Rebuild the app state from storage | Variant and test mode are both kept | None | US-7/AC-2, US-8/AC-3 |
| IT-7 | Test mode with saved games | Saved normal games in both variants; test mode off | Toggle test mode; switch variant; toggle off; switch back | Each toggle discards the current variant's game and starts one of the matching kind; a target game of the other kind is discarded on switching; test mode stays the same across variants | Random source | EC-5, EC-6, C-29 |

## 7. Component tests

| ID | Subject | Given | When | Then | Test doubles | Covers |
| -- | ------- | ----- | ---- | ---- | ------------ | ------ |
| CT-1 | Controls | Empty entry | Tap Enter; tap Delete | No message, no state change, no shake | Game state | EC-8, EC-9 |
| CT-2 | Banner | Two queued banners | Advance the clock; separately, tap a showing banner | First shows for 2.8 s, 0.3 s gap, then the second; a tap dismisses it and the next follows after 0.3 s | Clock, game state | C-17, US-3/AC-4 |
| CT-3 | Progress | 0, 1 and 22 of 22 found | Render | "0 of 22", "1 of 22", "22 of 22"; bar width 0%, 4.5%, 100%; markers at 35% and 70% | Game state | C-14, US-3/AC-1 |
| CT-4 | Fixed text, per variant | en-GB and en-US | Render header, rules, controls, empty shelf and picker | Text equals Nine Tile's[^ninetile-gb][^ninetile-us], with "word9" as the title and "centre" or "center"; level labels "Up to 30 words", "31 to 50 words", "Over 50 words" | Game state | C-10, C-13 |
| CT-5 | Theme | System light; system dark | Read theme values | Each colour equals Nine Tile's for that mode (section 10); there's no theme control in settings | None | C-18 |
| CT-6 | Settings text | en-GB and en-US | Render settings | Options read "English (UK)" and "English (US)"; entry reads "Licences" in en-GB and "Licenses" in en-US | Game state | C-26, C-27 |
| CT-7 | Default variant | First launch with locale `en-US`, `en-GB`, `en-AU`, `fr-FR` | Start | English (US) for `en-US`, English (UK) for the rest | Storage (empty) | US-7/AC-1, EC-19 |
| CT-8 | Layout and rotation | Size 1024×768 landscape; size 1024×320 | Render; then change size with letters in the entry and a message showing | Content is centred at 440 pt; on the short size, every control can be reached by scrolling; found words, entry and message are kept | Game state | C-4, EC-16 |
| CT-9 | Input | Puzzle in progress | Send hardware key events (letter, Enter, Backspace, Escape); read focus | State unchanged; no text input is opened | Game state | B-1 |
| CT-10 | Fonts | Network access blocked in the test | Render the main screen | Text uses Bricolage Grotesque and Atkinson Hyperlegible, loaded from the app package | None | C-5, C-19 |
| CT-11 | Storage failure | Storage that fails every write | Submit a word; shuffle; choose a level | The game works and no error shows | Storage | EC-3 |

## 8. Unit tests

| ID | Subject | Given | When | Then | Test doubles | Covers |
| -- | ------- | ----- | ---- | ---- | ------------ | ------ |
| UT-1 | Word validation | Test puzzle, `loam` found. Entries: `oil` with the outer L (too short and no centre tile); `main`; `mail` with the outer L; `loam`; `lmno`; `mail` with the centre L | Submit | In order: `Too short: use at least 4 letters`; `Must include the centre letter L`; `Must include the centre letter L`; `Already found`; `“LMNO” isn't in the word list`; accepted | None | C-11, EC-12, US-1/AC-4 |
| UT-2 | Puzzle solving | The parity fixture (section 10) | Solve each puzzle | The solution list equals the fixture's, in the same order | None | C-9 |
| UT-3 | New puzzle | Levels 1 to 3; test mode on and off; a random source returning the same index twice | Start a puzzle | Comes from that level's 2,500; the centre letter is at position 5 of 9; test mode draws from the 25 test puzzles at Easy whatever level was chosen; the same index gives the same puzzle again | Random source | US-8/AC-2, EC-7, C-12b |
| UT-4 | Shuffle and Delete | Letters in the entry; playing and revealed puzzles | Shuffle; Delete | Shuffle empties the entry, keeps the centre tile and permutes the same eight outer letters; both act after a reveal too | Random source | US-1/AC-5, EC-11, C-12c |
| UT-5 | Banner selection | 20-word total. Found counts 6, 7, 13, 14, 19, 20; one word jumping from 6 to 14; a nine-letter word that also passes 35%; a further word after each banner | Find a word | No banner below 35%; `Good start!` at 7; `Great going!` at 14; `Puzzle complete!` at 20; the jump shows only `Great going!`; nine-letter banner comes first; no banner repeats in a puzzle | None | C-15, C-16, US-3/AC-2 |
| UT-6 | Words found | Words found in the order `nail`, `loam`, `alloy` | Read the list and count | Sorted `alloy`, `loam`, `nail`; count 3 | None | US-3/AC-1 |
| UT-7 | Dictionary address | A word per variant | Build the address | The variant's URL followed by the URL-encoded word | None | US-5/AC-1 |
| UT-8 | Accepted word | Test puzzle (22 answers), `moil` in accepted words only, 5 found | Submit `moil` | Accepted; count reads "6 of 23"; `moil` is listed after a reveal | None | C-12a |

## 9. Regression

None: new system.

## 10. Test data and environments

| Item | Used by | Description |
| ---- | ------- | ----------- |
| Test puzzle | AT-1 to AT-12, UT-1, UT-8 | `nominally`, centre `l`, Easy, en-GB. Answers (22): alimony, alloy, ally, inlay, lain, lily, lion, loam, loan, loin, loyal, mail, mainly, mall, manly, mill, nail, nominal, nominally, nylon, oily, only. Taken from Nine Tile's data at `3543b45`. |
| Word-data digests | IT-1, IT-2 | SHA-256 of the sorted-key, no-whitespace JSON of `{d, dict, lang, p, v, x}`, as in Nine Tile's `DATA`. en-GB `9d2a8fb2c664e44ba504b8ba01514749b5dd661b9750366a3a77991b75fe8868`; en-US `1afe57160420637d1659045b0cc8b82bf44e39878d2a71869a890cff16474f2c`. Stored in word9's tests. |
| SCOWL archive | IT-1 | `scowl-2020.12.07.tar.gz`, SHA-256 `5587667caa20c4891390c2d42dbb4d5c4c3f41bee77af1457ece3ba23fb859cc`. Rebuilding with Nine Tile's script reproduced `DATA` exactly on 2026-11-01. |
| Parity fixture | UT-2 | Sample puzzles with expected solutions, generated once from Nine Tile's own JavaScript `solve` at `3543b45` and committed as a static file: all 25 test-pool puzzles and 10 per level, for each variant. |
| Palette values | CT-5 | Light and dark colours from Nine Tile's stylesheet at `3543b45`: `bg`, `surface`, `ink`, `muted`, `line`, `tile`, `tile-ink`, `tile-used`, `anchor`, `anchor-ink`, `accent`, `good`, `bad`. |
| Android emulator, iOS simulator | Automated acceptance | Recent Android phone image and iPhone simulator. |
| Android tablet or foldable | CT-8 (optional real check) | Widget tests use sizes only, so no device is required. |
| Release builds, phones | `@manual` tests, NF-5, NF-10 | Release builds installed from Diawi on one Android phone and one registered iPhone. |
| Performance devices | NF-1 to NF-3 | **Blocked**: see the open question in section 5. |

## 11. Not tested

| Spec item | Reason |
| --------- | ------ |
| C-2 | Flutter's own defaults at build time: checked by reading the build configuration in review. |
| C-33 | Store forms: verified by a person at release. |
| C-34 | App Store review notes: verified by a person at release. |
| C-35 | Icon approval, screenshots and listing text: verified by a person at release. |
| R-3 | Closed test and production access: verified by a person at release. |
| R-4 | Going live on both stores: verified by a person at release. |
| Pixel-identical look (excluded by C-19) | The spec doesn't require it, so there are no golden-image tests. Layout is checked in review. |
| Out-of-scope items in section 6 | The spec excludes them. |

[^ninetile-gb]: Nine Tile web app, en-GB variant, https://github.com/opichon/ninetile/blob/3543b45/src/index.html
[^ninetile-us]: Nine Tile web app, en-US variant, https://github.com/opichon/ninetile/blob/3543b45/src/en-us/index.html
