# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Pawfect Match is a Godot 4.x cat-matchmaking game. A lofi prototype of the core loop is playable: studio → cat picker → match check → cafe date → result → back to the studio. It uses placeholder shapes and a shared theme; only the cats and the studio background are real art.

- GDScript only — do not use C#.
- Renderer: Compatibility (GL Compatibility, also for mobile); target platform is a web export.
- Base resolution 1920x1080, stretch mode `canvas_items` (aspect `keep`): the game keeps its 16:9 shape and is centred, with black bars in wider or taller windows. Screens are laid out for exactly 1920x1080.
- Physics: Jolt Physics (3D).

## Game rules

Source: the "Pawfect Match – Layout Prototype" design canvas (https://claude.ai/artifact/MAYDDiRJaqMmtYGfvPEW6y). Cat names, traits and numbers there are placeholders. Mockup frames are 1280x720; multiply positions/sizes by 1.5 for 1920x1080.

- **Flow:** title → studio hub → pick two cats (pair tray) → match check → up to 3 dates → result screen after each date.
- **Match check:** shows compatibility (hearts out of 5), shared traits/likes, clashing traits, and each cat's **willingness** (a percentage).
- **Dates** (fixed order):
  1. Cafe — always happens.
  2. Park — if both cats liked date 1, or a willingness roll says yes.
  3. Seafood place — if date 2 went at least Okay.
- **During a date:** a timed minigame choice panel (e.g. remind a cat what the other likes), per-cat mood meters, score, and perks usable during the date.
- **Results** (per date):
  - **Great** — both cats loved it (3 hearts); next date unlocks.
  - **Okay** — one cat is unsure (2 hearts); that cat's willingness % decides whether the next date happens.
  - **Failed** — neither wants another date (0 hearts); the pair goes back to the studio and can be matched again later.
  - Each result gives treats + XP (more for better results; Failed still gives a little XP). XP raises the player level.

### Prototype rules

Rules decided while building the lofi prototype, for things the canvas does not define. Each number is a named constant in the file given, so it can be tuned there.

- **Compatibility** (`scripts/compatibility.gd`): start at 3 hearts, +1 per shared trait or like, -1 per clash, kept between 0 and 5. Clashes are pairs of opposite traits listed in `CLASHES` (Lazy vs Energetic, Shy vs Chatty).
- **Cafe date** (`scripts/date.gd`): 4 rounds of 30 seconds, two questions about each cat (one on a like, one on a trait). In each question one cat has forgotten something about the other.
  - Both cats start at mood 20% + 10% per compatibility heart.
  - A right answer gives +20 mood to the cat the question is about; a wrong answer or a timeout gives -15.
  - Each cat has an "i" bubble that opens its profile card; the timer keeps running while it is open.
  - Score: 100 per right answer plus 10 per second left.
- **Outcome:** a cat loved the date if its mood ends at 60% or more (`LOVED_IT_MOOD` in `scripts/game_state.gd`). Both cats: Great. One: Okay. Neither: Failed.
- **Rewards** (`scripts/result.gd`): Great 20 treats / 80 XP, Okay 10 / 40, Failed 0 / 15.
- **Level** (`scripts/game_state.gd`): level 1 at the start, one more per 100 XP.
- **Cooldown** (`scripts/game_state.gd`): after a Failed date that pair needs a 10-minute break (`COOLDOWN_SECONDS`); the cat picker blocks the pair and shows a countdown. Other pairs are not affected.

### Not built yet

Title screen, dates 2 and 3 (park, seafood place), the willingness roll, perks, treats shop, profile, settings, saving, sound, and final art for backgrounds, hearts and UI.

## Project structure

- `assets/` holds art and the UI theme: `assets/cats/`, `assets/studio/`, `assets/ui/lofi_theme.tres`.
- `scenes/` holds one scene per screen: `studio`, `cat_picker`, `match_check`, `date`, `result`. `main.tscn` (project root) is the start scene and opens the studio right away; it can become the title screen later.
- `scripts/` holds one script per scene, with the same name, plus the shared scripts below.

Shared pieces:

- `scripts/cat_data.gd` (`CatData.CATS`): the list of cats, each a Dictionary with name, age, personality, traits, likes, willingness, image and `faces` (which way the picture looks, used to mirror cats on the date).
- `scripts/game_state.gd`: the `GameState` autoload. It remembers the picked pair, the last date's moods, score and outcome, treats, XP and cooldowns between screens.
- `scripts/compatibility.gd` (`Compatibility.check`): hearts, shared list and clash list for two cats. Used by the match check and the date.
- `scripts/date_questions.gd` (`DateQuestions.make_questions`): builds the questions for a date.
- `scenes/cat_card.tscn`: the reusable cat card, used by the cat picker, the match check and the date's profile popup. `show_as_profile()` hides its Select button.
- `assets/ui/lofi_theme.tres`: the light theme (panels, buttons, labels, progress bars). Applied on the root node of each screen except the studio, whose labels sit on the dark background.

Screens switch with `get_tree().change_scene_to_file()`. A screen passes data to the next one by writing it to `GameState`. The match check, date and result screens fall back to test values when run on their own (F6).

To add a cat: add an entry to `CATS` in `scripts/cat_data.gd`, put its image in `assets/cats/`, and give it a spot in `CAT_POSITIONS` in `scripts/studio.gd`. The cat picker shows three cards per row and has no paging yet.

## Working with Godot files

- `project.godot` is engine-managed; prefer changing settings through the Godot editor rather than hand-editing.
- `.godot/` is a generated cache (git-ignored). Never edit or rely on files in it.
- `*.import` files are generated by Godot alongside imported assets; don't hand-edit them.
- `*.uid` files are generated by Godot alongside scripts; don't hand-edit them. Both `*.import` and `*.uid` files are committed.
- Autoloads (such as `GameState`) are registered in the editor: Project Settings → Globals → Autoload.
- Resource paths use the `res://` prefix (project root).

## Conventions

- Files are UTF-8 with LF line endings (`.editorconfig`, `.gitattributes`).
- Asset file names are lowercase without spaces (for example `mochi.png`); the web export is case-sensitive.
- Scripts are commented for beginners: explain what a block does and why, in plain language.
- `/android/` (export templates) and everything in `/build/` (export output) are git-ignored, except `build/.gdignore`.

## Git workflow

This is a team project. `main` and `develop` are both protected by GitHub rulesets: direct pushes, force pushes and deletion are refused, so all changes reach them through pull requests (PRs). Review and comments happen on the PR.

- `main` — stable versions only. Changes arrive only via a PR from `develop` (base `main`, compare `develop`), which needs 1 approval from a teammate with write access.
- `develop` — where finished features collect. Never change files directly on `develop`. Changes arrive only via PRs from feature branches (no approval required).
- `feature/<short-name>` — one branch per task, created from an up-to-date `develop` (`git pull` first).
- Every time work starts, first create a new feature branch from `develop`, before changing any files.
- Flow: feature branch → review the diff with the user → commit → push the branch → open a PR into `develop` (Claude uses `gh pr create --base develop`) → merge on GitHub → `git pull` on `develop` → delete the feature branch.
- Get the user's explicit approval before each commit, push, PR, merge and branch deletion.
- Claude may merge or close a PR (`gh pr merge` / `gh pr close`) only after the user's explicit approval for that specific PR.
- Remote: `origin` → https://github.com/aruorg/pawfect-match-game (GitHub). `main` and `develop` track their `origin` counterparts.

## Running

- Editor: press F5 to run the main scene (`main.tscn`, which opens the studio). F6 runs the scene that is open in the editor.
- Nothing is saved between sessions: treats, XP and cooldowns reset when the game closes.
- The prototype has been tested in the editor only; the web export has not been tested with it yet.
- Browser: the "Web" preset in `export_presets.cfg` is runnable — use the Remote Debug button (top right, after Stop) to export and open the game in a browser. Thread Support is off so it works on hosts without cross-origin isolation headers.
- Export output goes to `build/web/` (generated, git-ignored). `build/.gdignore` is committed and keeps Godot from importing exported files.
- No build scripts or test framework yet.
