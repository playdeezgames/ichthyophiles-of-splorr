# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

**Ichthyophiles of SPLORR!!**, the game the user first called "Feed the Fish": a virtual pet in which you keep a single fish alive on the real clock, neither overfed nor starved. The metaphor, in the user's words, is "quite literally that people are bad at taking care of things." By TheGrumpyGameDev, started November 8, 2026. Odin compiled to `js_wasm32`, a plain DOM page of text and buttons (no canvas).

`DESIGN.md` is the specification: the user's decisions (dated, in their words), the rules worked out from them, and all the wording, every line approved by the user. Do not change wording or rules without the user; only the user moves an item from Open to Decided. The MVP was built November 8, 2026; the Tamagotchi picture and LootLocker scores come after it, details to be settled with the user then.

The vault at `/home/yermom/git/bok-of-splorr/splorr/` is the shared body of knowledge for all SPLORR!! games and holds the standing rules. Read its `Home.md` first. This game's note is `Games/Ichthyophiles of SPLORR!!.md` (it links to `Concepts/Feed the Fish.md` and `Concepts/Fifty Games.md`). When a decision or a fact about the game changes, update that note and its `Home.md` row as well.

## Commands

```bash
tools/test.sh            # native tests (odin test, one thread) and then the real wasm build
tools/build.sh [--size]  # wasm build into build/web (--size for shipping)
tools/serve.sh           # build and serve on http://localhost:${PORT:-8000}/
tools/pages.sh           # tests, size build, copy into docs/ for GitHub Pages; never commits or pushes
```

One test: `odin test odin -define:ODIN_TEST_THREADS=1 -define:ODIN_TEST_NAMES=fish.<test_name>`. Always run the wasm build too (`tools/test.sh` does): `int` is 32 bits on `js_wasm32`, so times are `i64` milliseconds throughout.

## Architecture (package `fish` in `odin/`)

- `rules.odin`: the pure game. The clock is always an argument (`now`, ms since the epoch); nothing ticks. A living fish is `food_ms` and `hunger_ms` as of `updated_ms`; `advance(g, now)` replays the time since (food eaten and hunger wearing off together while there is food, hunger building while the tank is empty) and kills the fish at the exact moment it starves or its doomed hour ends, so a fish can die while the page is closed. `feed` dooms the fish when the food reaches five days (rounded up to the minute, because eating is continuous) and kills a doomed fish at once.
- `text.odin`: the approved wording (descriptions by food minus hunger, death messages, names, How to Play, reset text) and duration formatting.
- `screens.odin`: the view model. `make_view` lists elements (`Elem_Kind`: title, text, name, stat, button, text box) for the current `Screen`; `click(action)` and `submit_name(text)` run the buttons. Strings are in the temp allocator.
- `save.odin`: a versioned JSON save of `Game`, every field range-checked; a bad save is ignored.
- `web.odin` (`#+build js`): imports `now_ms`, `dom_clear/dom_add/dom_end`, `read_text`, `storage_get/set`; exports `on_click(action)`, `on_submit_name()`, `on_tick()`. Every event advances, saves, and redraws (`settle`).
- `web/index.html`: renders the elements as real DOM (`textContent` only), keeps a half-typed rename across the per-minute refresh, ticks on each minute and when the tab returns, saves under the `localStorage` key `ichthyophiles-of-splorr-save` (itch.io serves every game from one origin). **Its `KIND` table and `SAVE_NAME` number must match `Elem_Kind` and `Action`**; `element_kinds_match_the_page` pins them.
- Tests are `*_test.odin` (`#+build !js`).

## Release

- **Live on GitHub Pages: https://playdeezgames.github.io/ichthyophiles-of-splorr/** (since November 8, 2026; Pages serves `main` `/docs`, so run `tools/pages.sh`, commit `docs/` and push, on the user's word, to update it). On the portal (`oeuvre-of-splorr`) since November 8, 2026. **itch.io first release booked in Coxswain for November 14, 2026 (ship 21, channel `html`)**; booking is not permission, ship only on the user's "ship".
- Still to add per the vault's `Tech/Release standard.md` before release: `ITCH_DESCRIPTION.md`, `assets/cover.png` (630 by 500), `assets/screenshots/`, `devlog/YYYYMMDD/`, `tools/ship.sh` plus the one-line `shippit.sh` wrapper (pushes only with `--push`), and the footer "Send feedback" link (shared LootLocker form, `Tech/LootLocker.md`; needs a LootLocker game, which is the user's to create or approve). The footer already has the back links and the AI-use line.

## Rules

- Never `git push`, `shippit.sh --push`, `tools/ship.sh --push` or `butler push` unless the user says so. "Push" means `git push`; "ship" means itch.io. One itch.io release a day, booked through Coxswain (`ship_today` before any ship).
- On itch.io and in page copy the game is a "Metaphor", never a "Game". Anything an AI agent posts on itch.io says it was posted by an AI agent.
- Do not describe or "fix" a deliberate design choice as a problem (for example, a new fish arrives hungry and looks "lean" at once; while it recovers, its description holds still).

## Where it comes from

Game 02 of `playdeezgames/fifty-games` (a VB.NET console game): feeding added a day, seven days ahead was overfeeding, and the fed-until time passing was starvation. `DESIGN.md` supersedes it.
