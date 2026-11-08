package fish

import "core:encoding/json"
import "core:mem"

// The save: a versioned JSON document of the Game. Every field is range-checked on load, and a
// failed load leaves the game untouched. Timestamps are milliseconds, exact in a JSON number.

SAVE_VERSION :: 1

Save_Data :: struct {
	version:    int,
	has_fish:   bool,
	death:      int,
	name:       string,
	born_ms:    i64,
	updated_ms: i64,
	food_ms:    i64,
	hunger_ms:  i64,
	fed_ms:     i64,
	doomed_ms:  i64,
	died_ms:    i64,
	starved:    int,
	overfed:    int,
	best_ms:    i64,
}

@(private = "file")
scratch: [1 << 14]u8

@(private = "file")
scratch_allocator :: proc() -> mem.Allocator {
	@(static) arena: mem.Arena
	mem.arena_init(&arena, scratch[:])
	return mem.arena_allocator(&arena)
}

// The result lives in a package buffer until the next save_encode or save_decode.
save_encode :: proc(g: ^Game) -> (text: string, ok: bool) {
	d := Save_Data {
		version    = SAVE_VERSION,
		has_fish   = g.has_fish,
		death      = int(g.death),
		name       = name_of(g),
		born_ms    = g.born_ms,
		updated_ms = g.updated_ms,
		food_ms    = g.food_ms,
		hunger_ms  = g.hunger_ms,
		fed_ms     = g.fed_ms,
		doomed_ms  = g.doomed_ms,
		died_ms    = g.died_ms,
		starved    = g.starved,
		overfed    = g.overfed,
		best_ms    = g.best_ms,
	}
	data, err := json.marshal(d, {}, scratch_allocator())
	if err != nil {
		return "", false
	}
	return string(data), true
}

// Replaces g only if the whole document is valid.
save_decode :: proc(g: ^Game, text: string) -> bool {
	d: Save_Data
	if json.unmarshal(transmute([]u8)text, &d, allocator = scratch_allocator()) != nil {
		return false
	}
	if d.version != SAVE_VERSION {
		return false
	}
	if d.death < 0 || d.death >= len(Death) || d.starved < 0 || d.overfed < 0 || d.best_ms < 0 {
		return false
	}
	out: Game
	out.has_fish = d.has_fish
	out.death = Death(d.death)
	out.starved = d.starved
	out.overfed = d.overfed
	out.best_ms = d.best_ms
	if d.has_fish {
		if !set_name(&out, d.name) || len(d.name) > NAME_CAP {
			return false
		}
		if d.born_ms <= 0 || d.updated_ms < d.born_ms {
			return false
		}
		if d.food_ms < 0 || d.food_ms > OVERFEED_MS + FEED_MS || d.hunger_ms < 0 || d.hunger_ms > STARVE_MS {
			return false
		}
		if d.fed_ms < 0 || d.doomed_ms < 0 || d.died_ms < 0 {
			return false
		}
		if out.death == .None && d.doomed_ms != 0 && d.food_ms < OVERFEED_MS - DAY_MS {
			// a doomed fish holds about five days of food (less what an hour eats)
			return false
		}
		if out.death != .None && d.died_ms < d.born_ms {
			return false
		}
		out.born_ms = d.born_ms
		out.updated_ms = d.updated_ms
		out.food_ms = d.food_ms
		out.hunger_ms = d.hunger_ms
		out.fed_ms = d.fed_ms
		out.doomed_ms = d.doomed_ms
		out.died_ms = d.died_ms
	} else if out.death != .None {
		return false
	}
	g^ = out
	return true
}
