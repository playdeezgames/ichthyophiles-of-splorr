package fish

// The rules of DESIGN.md, with no platform imports. The clock is always an argument (`now`,
// milliseconds since the epoch), never read here, so tests can run days in microseconds.

MINUTE_MS :: i64(60_000)
HOUR_MS :: 60 * MINUTE_MS
DAY_MS :: 24 * HOUR_MS

FEED_MS :: DAY_MS // one Feed adds one day's worth of food
OVERFEED_MS :: 5 * DAY_MS // this much food in the tank dooms the fish
DOOM_MS :: HOUR_MS // a doomed fish dies this long after the fatal feeding
STARVE_MS :: 5 * DAY_MS // this much hunger kills the fish

NAME_MAX_RUNES :: 40
NAME_CAP :: NAME_MAX_RUNES * 4 // UTF-8 bytes

Death :: enum u8 {
	None,
	Starved,
	Overfed,
}

Game :: struct {
	// The current fish, if any. A dead fish stays until the player gets a new one.
	has_fish:   bool,
	death:      Death, // .None while the fish lives
	name:       [NAME_CAP]u8,
	name_len:   int,
	born_ms:    i64,
	updated_ms: i64, // the state below is true as of this moment
	food_ms:    i64, // food in the tank
	hunger_ms:  i64, // how starved it is
	fed_ms:     i64, // last feeding, 0 for never
	doomed_ms:  i64, // the fatal feeding, 0 for not doomed
	died_ms:    i64,

	// The player's record.
	starved:    int,
	overfed:    int,
	best_ms:    i64, // the longest finished life
}

alive :: proc(g: ^Game) -> bool {
	return g.has_fish && g.death == .None
}

doomed :: proc(g: ^Game) -> bool {
	return alive(g) && g.doomed_ms != 0
}

name_of :: proc(g: ^Game) -> string {
	return string(g.name[:g.name_len])
}

// Brings the fish up to `now`: food is eaten, hunger builds or wears off, and the fish dies at
// the exact moment it starves or its doomed hour ends. A clock that went backwards is ignored.
advance :: proc(g: ^Game, now: i64) {
	if !alive(g) || now <= g.updated_ms {
		return
	}
	t := g.updated_ms
	end := now
	overdue := g.doomed_ms != 0 && g.doomed_ms + DOOM_MS <= now
	if overdue {
		end = g.doomed_ms + DOOM_MS
	}
	// While there is food, it is eaten and hunger wears off at the same rate.
	if g.food_ms > 0 {
		e := min(end - t, g.food_ms)
		g.food_ms -= e
		g.hunger_ms = max(0, g.hunger_ms - e)
		t += e
	}
	// With the tank empty, hunger builds.
	if t < end {
		g.hunger_ms += end - t
		if g.hunger_ms >= STARVE_MS {
			die(g, end - (g.hunger_ms - STARVE_MS), .Starved)
			return
		}
		t = end
	}
	g.updated_ms = end
	if overdue {
		die(g, end, .Overfed)
	}
}

@(private = "file")
die :: proc(g: ^Game, at: i64, how: Death) {
	g.death = how
	g.died_ms = at
	g.updated_ms = at
	if how == .Starved {
		g.hunger_ms = STARVE_MS
		g.starved += 1
	} else {
		g.overfed += 1
	}
	g.best_ms = max(g.best_ms, at - g.born_ms)
}

// Only when there is no living fish. The new fish arrives with an empty tank.
get_fish :: proc(g: ^Game, now: i64, name: string) -> bool {
	if alive(g) {
		return false
	}
	g.has_fish = true
	g.death = .None
	g.born_ms = now
	g.updated_ms = now
	g.food_ms = 0
	g.hunger_ms = 0
	g.fed_ms = 0
	g.doomed_ms = 0
	g.died_ms = 0
	set_name(g, name)
	return true
}

// One day's worth of food. Reaching five days' worth dooms the fish; feeding a doomed fish
// kills it at once.
feed :: proc(g: ^Game, now: i64) -> bool {
	advance(g, now)
	if !alive(g) {
		return false
	}
	g.fed_ms = now
	if g.doomed_ms != 0 {
		die(g, now, .Overfed)
		return true
	}
	g.food_ms += FEED_MS
	// The food is eaten continuously, so presses a few seconds apart leave slightly less than
	// five days' worth; the check rounds up to the whole minute (the smallest unit shown).
	if (g.food_ms + MINUTE_MS - 1) / MINUTE_MS * MINUTE_MS >= OVERFEED_MS {
		g.doomed_ms = now
	}
	return true
}

// Trims spaces and keeps at most NAME_MAX_RUNES characters. An empty name is refused.
set_name :: proc(g: ^Game, name: string) -> bool {
	s := trim_spaces(name)
	if len(s) == 0 {
		return false
	}
	n, runes := 0, 0
	for i := 0; i < len(s) && runes < NAME_MAX_RUNES; {
		w := utf8_width(s[i])
		if i + w > len(s) {
			break
		}
		i += w
		n = i
		runes += 1
	}
	g.name_len = copy(g.name[:], trim_spaces(s[:n]))
	return true
}

// Food minus hunger: between -5 and +5 days. Picks the description.
condition_ms :: proc(g: ^Game) -> i64 {
	return g.food_ms - g.hunger_ms
}

// The longest life, counting the living fish too.
longest_ms :: proc(g: ^Game, now: i64) -> i64 {
	if alive(g) {
		return max(g.best_ms, now - g.born_ms)
	}
	return g.best_ms
}

// Every fish the player has had: the dead ones are counted, plus a living one.
fish_count :: proc(g: ^Game) -> int {
	return g.starved + g.overfed + (alive(g) ? 1 : 0)
}

// Forgets everything: the record and the fish.
reset :: proc(g: ^Game) {
	g^ = {}
}

@(private = "file")
trim_spaces :: proc(s: string) -> string {
	a, b := 0, len(s)
	for a < b && (s[a] == ' ' || s[a] == '\t' || s[a] == '\n' || s[a] == '\r') {
		a += 1
	}
	for b > a && (s[b - 1] == ' ' || s[b - 1] == '\t' || s[b - 1] == '\n' || s[b - 1] == '\r') {
		b -= 1
	}
	return s[a:b]
}

@(private = "file")
utf8_width :: proc(c: u8) -> int {
	switch {
	case c < 0x80:
		return 1
	case c >= 0xF0:
		return 4
	case c >= 0xE0:
		return 3
	case c >= 0xC0:
		return 2
	}
	return 1 // a stray continuation byte counts as one
}
