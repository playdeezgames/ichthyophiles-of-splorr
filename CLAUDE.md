# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

The home of the game idea the user calls **"Feed the Fish"** (repo name `ichthyophiles-of-splorr`), by TheGrumpyGameDev. Started November 8, 2026. **It is in the planning stage: the gameplay is being worked out with the user first, and there is no code, build or test step yet.** Do not scaffold code, choose a stack or invent mechanics ahead of the user; record what they decide, in their words, with the date.

The vault at `/home/yermom/git/bok-of-splorr/splorr/` is the shared body of knowledge for all SPLORR!! games and holds the standing rules. Read its `Home.md` first. This game's note is `Games/Ichthyophiles of SPLORR!!.md`; it links to the earlier idea note (`Concepts/Feed the Fish.md`) and the Fifty Games list (`Concepts/Fifty Games.md`). When a design decision or a fact about the game changes, update that note and its `Home.md` row as well.

## Where it comes from

Feed the Fish was game 02 of `playdeezgames/fifty-games` ("In which I make fifty games. In fifty weeks."; VB.NET console games on Spectre.Console), and its "Fifty Games.pdf" idea list files it under Simulation Games. The old version (`src/FeedTheFish/FeedTheFish.vb` there) runs on the real clock:

- You start with no fish; you can get a fish; with a fish, you can feed it.
- Getting a fish sets "fed until" to now plus one day; each feeding adds one more day.
- If "fed until" passes, the fish has starved; if a feeding pushes it more than seven days ahead, you overfed it and it dies.
- With a dead fish you can get a new one. Fish starved and fish overfed are counted.

That is the starting point, not a specification: how much of it the new game keeps is the user's call.

## Planned release

- **GitHub Pages first, itch.io later**, and only once the user is satisfied that it lives up to the concept. The repo is already public. Do not book a ship in Coxswain until the user asks.
- When code exists, follow the vault's `Tech/Release standard.md` (`ITCH_DESCRIPTION.md`, `assets/cover.png` at 630 by 500, `assets/screenshots/`, `devlog/YYYYMMDD/`, `tools/ship.sh` plus the one-line `shippit.sh` wrapper that pushes only with `--push`, `tools/pages.sh` into `docs/`) and give the page the footer back links and the "Send feedback" LootLocker link (`Tech/LootLocker.md`).
- Most SPLORR!! games are Odin compiled to `js_wasm32` (vault `Tech/Odin wasm recipe.md`); that is the house default, not a decision for this game until the user makes it.

## Rules

- Never `git push`, `shippit.sh --push`, `tools/ship.sh --push` or `butler push` unless the user says so. "Push" means `git push`; "ship" means itch.io. One itch.io release a day, booked through Coxswain (`ship_today` before any ship).
- On itch.io and in page copy the game is a "Metaphor", never a "Game". Anything an AI agent posts on itch.io says it was posted by an AI agent.
- Do not describe or "fix" a deliberate design choice as a problem.
