# Ichthyophiles of SPLORR!!: design

The game the user called "Feed the Fish" (game 02 of `fifty-games`). This file records the user's decisions, with dates, then the rules worked out from them, drafts awaiting the user's edits, and what is still open. Only the user moves an item to "Decided".

## Decided

### November 8, 2026: the concept (the user's words)

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
- **Stack and look:** "an odin/wasm game that uses text and buttons only." The user likes "the idea of a tamagotchi graphics showing the state of the fish."
- **Online scores:** "a good candidate for bring in loot locker for high scores regarding how long people's fishes live." (vault `Tech/LootLocker.md`; Chem-Grid is the reference).

### November 8, 2026: answers to the open questions

1. **One feeding adds one day's worth of food.**
2. **Hunger recovers slowly:** feeding a starving fish does not wipe its hunger. While it has food, its hungry days wear off at **one per day**, the same rate they built up.
3. **Overfeeding kills later, unseen:** the fish dies **one hour** after the feeding that brought the food to five days' worth, even if the page stays open. During that hour it **looks unwell** (its own description, a hint that something is wrong, too late to fix).
4. **The Tamagotchi picture comes after the MVP.**
5. **LootLocker scores come after the MVP**; the MVP keeps its stats on the player's device.
6. **Descriptions:** Claude drafts them for the user to edit (drafts below). **One per day of state**, and a fish with both food and hungry days is described by **food minus hunger** (one number).
7. **Start:** "You have no fish!" and a **Get a Fish** button. **A new fish arrives with an empty tank**, so its starvation clock starts at once.
8. **Longest living counts the living fish too:** if the current fish passes the record, the record shows it and keeps climbing. Lifespans are shown in **days, hours and minutes**.
9. **Also on the main screen:** the fish's **age**, the **time since it was last fed**, a **name** (random, and the player can rename it), and a **How to Play** button.

### November 8, 2026: the remaining small questions

1. **Feeding a doomed fish kills it at once** (by overfeeding).
2. **Renaming: both** a text box to type a name (up to **40 characters**) and a button for another random name from the list.
3. **An open page updates the fish every minute.**
4. **Reset, with a guilt trip:** a reset button that names how many fish the player is trying to forget before it lets them. It wipes **the stats and the fish**, back to "You have no fish!" (wording below, a draft).
5. **The Tamagotchi picture and the LootLocker leaderboard are settled when we get there**, after the MVP.

## The rules, worked out from the decisions

The state of a living fish is two hidden amounts, in days, plus timestamps:

- **food**: what is in the tank. Each Feed adds 1. While food is above 0 it is eaten at 1 per real day.
- **hunger**: how starved it is. While food is 0, hunger grows at 1 per real day. While food is above 0, hunger falls at 1 per real day, down to 0.
- **Starvation:** hunger reaching 5 kills the fish, at the exact moment it reaches 5.
- **Overfeeding:** a Feed that brings food to 5 or more dooms the fish; it dies exactly one hour after that feeding. Feeding it again during that hour kills it at once.
- **Condition:** `food - hunger`, a number between -5 and +5, picks the description. A doomed fish shows the "unwell" description instead.
- **Real clock:** nothing ticks in the background. When the page opens (and every minute while it is open) the game advances the state from the saved timestamps to now, and if the fish died while the page was closed, says when and how.
- **Stats:** fish overfed, fish starved, longest life (the best of all finished lives and the current fish's age). A life runs from Get a Fish to death.

Two consequences worth knowing (not problems; the design as decided):

- While a fish has food and is still recovering hunger, food and hunger fall together, so `food - hunger` and the description hold still until the hunger is gone.
- A new fish with an empty tank dies after five presses of Feed in a row, and starves in five days if never fed.

## Wording

Drafted by Claude, reviewed one section at a time and **all approved by the user on November 8, 2026**. Keep the wording; changes are the user's.

### Descriptions (condition = food minus hunger)

**Approved by the user as written, November 8, 2026** ("love it. my favorite is 'Fish have ribs'"). Keep the wording.

| Condition | Draft |
|---|---|
| doomed (overfed, last hour) | Yer fish is floating a bit sideways and breathing hard. It does not look well. |
| 4 to 5 | Yer fish is a sphere with fins. It can barely turn around. |
| 3 to 4 | Yer fish is round as a marble and moves like it regrets everything. |
| 2 to 3 | Yer fish is chubby and pleased with itself. |
| 1 to 2 | Yer fish is plump and glossy. |
| 0 to 1 | Yer fish looks just right. |
| -1 to 0 | Yer fish is lean and keeps looking at you. |
| -2 to -1 | Yer fish is thin and nibbling at the gravel. |
| -3 to -2 | Yer fish is skinny. You can see its ribs. Fish have ribs. |
| -4 to -3 | Yer fish is gaunt and barely moving. |
| -5 to -4 | Yer fish is a skeleton with a hopeful look. |

### Death messages

User's direction (November 8, 2026): "add the fishes name" and "lay on the guilt for the playerr." **These two approved as written, November 8, 2026** ("keep them as is"; the extra random lines offered in chat were not taken). [name] is the fish's name, [time ago] e.g. "3 hours, 12 minutes ago" or "just now".

- Starved: "[name] starved to death [time ago]. [name] waited by the glass for you right up to the end. You had one job."
- Overfed: "[name] died of overeating [time ago]. [name] trusted you to know when to stop. You didn't."

### Fish names (random pick, renamable)

**Approved as written, November 8, 2026** ("fine"; the user was "especially tickled by 'Wanda'").

Bubbles, Finnegan, Gill Bates, Captain Wiggles, Sir Swims-a-Lot, Nemo's Cousin, Flounder, Goldie, Mr. Blub, Admiral Snack, Lil' Fin, Sushi (it does not know), Gordon, Wanda, Steve, Splashley, Bartholomew, Dorsal, Fishy McFishface, Gulp.

### How to Play

**Approved as written, November 8, 2026** ("keep it"; no closing jab).

You start with no fish. Get a fish. Feed the fish. Not too much: the fish dies if you overfeed it. Not too little: the fish dies if you starve it. Yer fish lives on the real clock, even when you are not looking. If yer fish dies, get a new fish.

### Reset (draft, not yet approved)

[N] counts every fish the player has had; the bracketed parts appear only when they apply.

> You are about to forget [N] fish. [S] you starved. [O] you overfed. [And [name], who is still alive and is about to be flushed.] They would not have forgotten you. Forget them anyway?

Buttons: **Forget them** / **Never mind**.

## Open

- After the MVP: the Tamagotchi picture (drawn how, and where on the page) and the LootLocker leaderboard (submit each finished life? the living record? player name or guest?). The user chose to settle these when we get there.
