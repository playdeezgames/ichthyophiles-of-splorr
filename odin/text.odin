package fish

import "core:fmt"
import "core:strings"

// Every line here was approved by the user on November 8, 2026 (DESIGN.md, "Wording").
// Keep the wording; changes are the user's.

DOOMED_TEXT :: "Yer fish is floating a bit sideways and breathing hard. It does not look well."

// Index 0 is "-5 to -4", index 9 is "4 to 5" (condition in whole days, rounded down).
CONDITION_TEXT := [10]string {
	"Yer fish is a skeleton with a hopeful look.",
	"Yer fish is gaunt and barely moving.",
	"Yer fish is skinny. You can see its ribs. Fish have ribs.",
	"Yer fish is thin and nibbling at the gravel.",
	"Yer fish is lean and keeps looking at you.",
	"Yer fish looks just right.",
	"Yer fish is plump and glossy.",
	"Yer fish is chubby and pleased with itself.",
	"Yer fish is round as a marble and moves like it regrets everything.",
	"Yer fish is a sphere with fins. It can barely turn around.",
}

FISH_NAMES := [20]string {
	"Bubbles",
	"Finnegan",
	"Gill Bates",
	"Captain Wiggles",
	"Sir Swims-a-Lot",
	"Nemo's Cousin",
	"Flounder",
	"Goldie",
	"Mr. Blub",
	"Admiral Snack",
	"Lil' Fin",
	"Sushi (it does not know)",
	"Gordon",
	"Wanda",
	"Steve",
	"Splashley",
	"Bartholomew",
	"Dorsal",
	"Fishy McFishface",
	"Gulp",
}

HOW_TO_PLAY :: "You start with no fish. Get a fish. Feed the fish. Not too much: the fish dies if you overfeed it. Not too little: the fish dies if you starve it. Yer fish lives on the real clock, even when you are not looking. If yer fish dies, get a new fish."

NO_FISH_TEXT :: "You have no fish!"

condition_text :: proc(g: ^Game) -> string {
	if doomed(g) {
		return DOOMED_TEXT
	}
	c := condition_ms(g)
	i := int(floor_div(c, DAY_MS)) + 5
	return CONDITION_TEXT[clamp(i, 0, len(CONDITION_TEXT) - 1)]
}

// "[name] starved to death [time ago]. ..." (temp allocator)
death_text :: proc(g: ^Game, now: i64) -> string {
	name := name_of(g)
	ago := ago_text(now - g.died_ms)
	switch g.death {
	case .Starved:
		return fmt.tprintf("%s starved to death %s. %s waited by the glass for you right up to the end. You had one job.", name, ago, name)
	case .Overfed:
		return fmt.tprintf("%s died of overeating %s. %s trusted you to know when to stop. You didn't.", name, ago, name)
	case .None:
	}
	return ""
}

// The approved reset text; the bracketed parts appear only when they apply. (temp allocator)
reset_text :: proc(g: ^Game) -> string {
	b := strings.builder_make(context.temp_allocator)
	fmt.sbprintf(&b, "You are about to forget %d fish.", fish_count(g))
	if g.starved > 0 {
		fmt.sbprintf(&b, " %d you starved.", g.starved)
	}
	if g.overfed > 0 {
		fmt.sbprintf(&b, " %d you overfed.", g.overfed)
	}
	if alive(g) {
		fmt.sbprintf(&b, " And %s, who is still alive and is about to be flushed.", name_of(g))
	}
	strings.write_string(&b, " They would not have forgotten you. Forget them anyway?")
	return strings.to_string(b)
}

// "3 days, 7 hours, 12 minutes"; leading zero units are left out. (temp allocator)
duration_text :: proc(ms: i64) -> string {
	m := max(ms, 0) / MINUTE_MS
	days, hours, minutes := m / (24 * 60), (m / 60) % 24, m % 60
	b := strings.builder_make(context.temp_allocator)
	unit :: proc(b: ^strings.Builder, n: i64, word: string) {
		if strings.builder_len(b^) > 0 {
			strings.write_string(b, ", ")
		}
		fmt.sbprintf(b, "%d %s%s", n, word, n == 1 ? "" : "s")
	}
	if days > 0 {
		unit(&b, days, "day")
	}
	if days > 0 || hours > 0 {
		unit(&b, hours, "hour")
	}
	unit(&b, minutes, "minute")
	return strings.to_string(b)
}

// "3 hours, 12 minutes ago", or "just now" under a minute. (temp allocator)
ago_text :: proc(ms: i64) -> string {
	if ms < MINUTE_MS {
		return "just now"
	}
	return fmt.tprintf("%s ago", duration_text(ms))
}

@(private = "file")
floor_div :: proc(a, b: i64) -> i64 {
	q := a / b
	if (a % b != 0) && ((a < 0) != (b < 0)) {
		q -= 1
	}
	return q
}
