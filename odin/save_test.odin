#+build !js
package fish

import "core:testing"

@(test)
save_round_trips :: proc(t: ^testing.T) {
	g: Game
	get_fish(&g, T0, "Sushi (it does not know)")
	feed(&g, T0 + HOUR_MS)
	advance(&g, T0 + DAY_MS)
	g.starved, g.overfed, g.best_ms = 3, 2, 4 * DAY_MS
	text, ok := save_encode(&g)
	testing.expect(t, ok)
	out: Game
	testing.expect(t, save_decode(&out, text))
	testing.expect_value(t, out, g)
}

@(test)
save_round_trips_a_dead_fish_and_no_fish :: proc(t: ^testing.T) {
	g: Game
	get_fish(&g, T0, "Gulp")
	advance(&g, T0 + 6 * DAY_MS)
	text, _ := save_encode(&g)
	out: Game
	testing.expect(t, save_decode(&out, text))
	testing.expect_value(t, out, g)

	empty: Game
	text, _ = save_encode(&empty)
	testing.expect(t, save_decode(&out, text))
	testing.expect_value(t, out, empty)
}

@(test)
bad_saves_leave_the_game_alone :: proc(t: ^testing.T) {
	g: Game
	get_fish(&g, T0, "Steve")
	before := g
	bad := []string {
		"",
		"not json",
		`{"version":2}`,
		`{"version":1,"has_fish":true,"death":0,"name":"","born_ms":1,"updated_ms":1}`,
		`{"version":1,"has_fish":true,"death":9,"name":"X","born_ms":1,"updated_ms":1}`,
		`{"version":1,"has_fish":true,"death":0,"name":"X","born_ms":1,"updated_ms":1,"food_ms":-5}`,
		`{"version":1,"has_fish":false,"death":1}`,
		`{"version":1,"starved":-1}`,
	}
	for s in bad {
		testing.expectf(t, !save_decode(&g, s), "accepted %q", s)
		testing.expect_value(t, g, before)
	}
}
