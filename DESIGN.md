# Ichthyophiles of SPLORR!!: design

The game the user called "Feed the Fish" (game 02 of `fifty-games`). This file records the user's decisions in their words, with dates, then what is still open. Only the user moves an item from "Open" to "Decided".

## Decided (November 8, 2026)

- **Name:** "Ichthyophiles of SPLORR!! is the name of the game."
- **Kind:** a "virtual pet".
- **The metaphor:** "quite literally that people are bad at taking care of things."
- **One fish:** "this is about keeping a single fish alive."
- **Feeding:** "you feed the fish, and can feed the fish as often as you like."
- **Overfeeding:** "if there is the amount of food worth of 5 days of feeding, then the fish will die."
- **Eating and starving:** "the food will get eaten over time, and when there is no food for 5 days, the the fish will die of starvation."
- **Time:** the real clock.
- **Feedback, hidden numbers:** "there should be descriptive feedback based on how fat or skinny the fish is based on how over or underfed it is, but you should not see how many days worth of food have been placed."
- **Stats:** the game "counts how many fish died of overfeeding, how many fish died of starvation, and the longest living fish that the player has taken care of."
- **MVP scope:** "for mvp, that is the whole game."
- **Stack and look:** "an odin/wasm game that uses text and buttons only." The user also likes "the idea of a tamagotchi graphics showing the state of the fish" (see Open).
- **Online scores:** "a good candidate for bring in loot locker for high scores regarding how long people's fishes live." (vault `Tech/LootLocker.md`; Chem-Grid is the reference).

## Working reading (to be confirmed by the user)

How the rules above would turn into a model. Not decided until the user says so.

- The state is the food in the tank, measured in days, plus how long the tank has been empty.
- Each feeding adds a fixed amount of food (one day's worth?). Food is eaten at one day's worth per real day.
- Food reaching five days' worth kills the fish at once, by overfeeding.
- Once the food runs out, a starvation clock starts; feeding stops it. Five days at empty kills the fish by starvation.
- So the fish's condition is one line from "five days empty" (starved) through "just fed" to "five days of food" (overfed), and the fat or skinny description is chosen from where it sits on that line.
- Because it is the real clock, everything is worked out from saved timestamps when the page opens; the fish can die while the page is closed, and the game reports when.
- A fish's life runs from getting it to its death; "longest living" is the best finished life (whether a living fish counts is open).

## Open

1. How much food one feeding adds (one day's worth, or something else).
2. Does feeding while the fish is starving reset the starvation clock fully?
3. Is death by overfeeding instant at the feeding that crosses five days, or does the fish die later as the food sits?
4. The descriptive feedback: how many bands, and the wording (the user's to write, or drafts for the user to edit).
5. Tamagotchi-style graphics: part of the MVP, or after it? Drawn how (pixel sprite on a canvas, text art)?
6. Starting a game: do you start with no fish and press "Get a fish", as in the old version?
7. Longest living: does the current fish count while alive, and is it shown in days, or days and hours?
8. LootLocker: in the MVP or after? Submit a fish's life when it dies, under a player name or a guest ID?
9. Anything else on screen: the fish's name, age, the time since last fed?
