# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

**Ichthyophiles of SPLORR!!**, the game the user first called "Feed the Fish": a virtual pet in which you keep a single fish alive on the real clock, neither overfed nor starved. The metaphor, in the user's words, is "quite literally that people are bad at taking care of things." By TheGrumpyGameDev, started November 8, 2026. Odin compiled to `js_wasm32`, text and buttons.

**It is in the planning stage: the gameplay is being worked out with the user first, and there is no code, build or test step yet.** `DESIGN.md` holds the decisions (in the user's words, dated), a working reading of the rules awaiting the user's confirmation, and the open questions. Do not scaffold code or invent mechanics ahead of the user; only the user moves an item from Open to Decided.

The vault at `/home/yermom/git/bok-of-splorr/splorr/` is the shared body of knowledge for all SPLORR!! games and holds the standing rules. Read its `Home.md` first. This game's note is `Games/Ichthyophiles of SPLORR!!.md`; it links to the earlier idea note (`Concepts/Feed the Fish.md`) and the Fifty Games list (`Concepts/Fifty Games.md`). When a design decision or a fact about the game changes, update that note and its `Home.md` row as well.

## Where it comes from

Feed the Fish was game 02 of `playdeezgames/fifty-games` ("In which I make fifty games. In fifty weeks."; VB.NET console games on Spectre.Console), and its "Fifty Games.pdf" idea list files it under Simulation Games. The old version (`src/FeedTheFish/FeedTheFish.vb` there) runs on the real clock:

- You start with no fish; you can get a fish; with a fish, you can feed it.
- Getting a fish sets "fed until" to now plus one day; each feeding adds one more day.
- If "fed until" passes, the fish has starved; if a feeding pushes it more than seven days ahead, you overfed it and it dies.
- With a dead fish you can get a new one. Fish starved and fish overfed are counted.

The new game differs (decided November 8, 2026): the overfeed and starvation limits are five days each, and the player never sees the amount of food, only a description of how fat or skinny the fish is. `DESIGN.md` is the specification, not the old code.

## Planned release

- **GitHub Pages first, itch.io later**, and only once the user is satisfied that it lives up to the concept. The repo is already public. Do not book a ship in Coxswain until the user asks.
- When code exists, follow the vault's `Tech/Release standard.md` (`ITCH_DESCRIPTION.md`, `assets/cover.png` at 630 by 500, `assets/screenshots/`, `devlog/YYYYMMDD/`, `tools/ship.sh` plus the one-line `shippit.sh` wrapper that pushes only with `--push`, `tools/pages.sh` into `docs/`) and give the page the footer back links and the "Send feedback" LootLocker link (`Tech/LootLocker.md`).
- Odin and `js_wasm32` (vault `Tech/Odin wasm recipe.md`). Online high scores for how long fish live are planned through LootLocker (vault `Tech/LootLocker.md`, Chem-Grid is the reference); when they arrive is open.

## Rules

- Never `git push`, `shippit.sh --push`, `tools/ship.sh --push` or `butler push` unless the user says so. "Push" means `git push`; "ship" means itch.io. One itch.io release a day, booked through Coxswain (`ship_today` before any ship).
- On itch.io and in page copy the game is a "Metaphor", never a "Game". Anything an AI agent posts on itch.io says it was posted by an AI agent.
- Do not describe or "fix" a deliberate design choice as a problem.
