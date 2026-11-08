#+build !js
package fish

import "core:testing"

T0 :: i64(1_800_000_000_000) // a fixed "now" for tests

@(private = "file")
fresh :: proc() -> Game {
	g: Game
	get_fish(&g, T0, "Bubbles")
	return g
}

@(test)
new_fish_has_an_empty_tank :: proc(t: ^testing.T) {
	g := fresh()
	testing.expect(t, alive(&g))
	testing.expect_value(t, g.food_ms, 0)
	testing.expect_value(t, g.fed_ms, 0)
	testing.expect_value(t, name_of(&g), "Bubbles")
	testing.expect_value(t, condition_text(&g), "Yer fish looks just right.")
}

@(test)
unfed_fish_starves_in_exactly_five_days :: proc(t: ^testing.T) {
	g := fresh()
	advance(&g, T0 + 5 * DAY_MS - 1)
	testing.expect(t, alive(&g))
	testing.expect_value(t, condition_text(&g), "Yer fish is a skeleton with a hopeful look.")
	advance(&g, T0 + 9 * DAY_MS) // the page was closed for days
	testing.expect_value(t, g.death, Death.Starved)
	testing.expect_value(t, g.died_ms, T0 + 5 * DAY_MS)
	testing.expect_value(t, g.starved, 1)
	testing.expect_value(t, g.best_ms, 5 * DAY_MS)
}

@(test)
one_feeding_a_day_keeps_it_level :: proc(t: ^testing.T) {
	g := fresh()
	now := T0
	for _ in 0 ..< 60 {
		feed(&g, now)
		now += DAY_MS
	}
	advance(&g, now)
	testing.expect(t, alive(&g))
	testing.expect_value(t, g.food_ms, 0)
	testing.expect_value(t, g.hunger_ms, 0)
	testing.expect_value(t, longest_ms(&g, now), 60 * DAY_MS)
}

@(test)
five_feedings_from_empty_doom_it_for_an_hour :: proc(t: ^testing.T) {
	g := fresh()
	for _ in 0 ..< 4 {
		feed(&g, T0)
	}
	testing.expect(t, !doomed(&g))
	testing.expect_value(t, condition_text(&g), "Yer fish is a sphere with fins. It can barely turn around.")
	feed(&g, T0)
	testing.expect(t, doomed(&g))
	testing.expect_value(t, condition_text(&g), DOOMED_TEXT)
	advance(&g, T0 + HOUR_MS - 1)
	testing.expect(t, alive(&g))
	advance(&g, T0 + HOUR_MS)
	testing.expect_value(t, g.death, Death.Overfed)
	testing.expect_value(t, g.died_ms, T0 + HOUR_MS)
	testing.expect_value(t, g.overfed, 1)
}

@(test)
five_quick_presses_doom_it_even_seconds_apart :: proc(t: ^testing.T) {
	g := fresh()
	for i in 0 ..< 5 {
		feed(&g, T0 + i64(i) * 5_000)
	}
	testing.expect(t, doomed(&g))
	// spread over more than a minute, the fish has eaten enough to survive the fifth
	g = fresh()
	for i in 0 ..< 5 {
		feed(&g, T0 + i64(i) * 20_000)
	}
	testing.expect(t, !doomed(&g))
}

@(test)
doomed_fish_dies_on_time_while_the_page_is_closed :: proc(t: ^testing.T) {
	g := fresh()
	for _ in 0 ..< 5 {
		feed(&g, T0)
	}
	advance(&g, T0 + 3 * DAY_MS)
	testing.expect_value(t, g.death, Death.Overfed)
	testing.expect_value(t, g.died_ms, T0 + HOUR_MS)
}

@(test)
feeding_a_doomed_fish_kills_it_at_once :: proc(t: ^testing.T) {
	g := fresh()
	for _ in 0 ..< 5 {
		feed(&g, T0)
	}
	feed(&g, T0 + 10 * MINUTE_MS)
	testing.expect_value(t, g.death, Death.Overfed)
	testing.expect_value(t, g.died_ms, T0 + 10 * MINUTE_MS)
	testing.expect(t, !feed(&g, T0 + 11 * MINUTE_MS))
	testing.expect_value(t, g.overfed, 1)
}

@(test)
hunger_wears_off_slowly_while_there_is_food :: proc(t: ^testing.T) {
	g := fresh()
	advance(&g, T0 + 3 * DAY_MS) // three days hungry
	testing.expect_value(t, g.hunger_ms, 3 * DAY_MS)
	feed(&g, T0 + 3 * DAY_MS)
	feed(&g, T0 + 3 * DAY_MS)
	// food 2, hunger 3: condition -1, and it holds while both fall together
	testing.expect_value(t, condition_ms(&g), -DAY_MS)
	advance(&g, T0 + 4 * DAY_MS)
	testing.expect_value(t, g.food_ms, DAY_MS)
	testing.expect_value(t, g.hunger_ms, 2 * DAY_MS)
	testing.expect_value(t, condition_ms(&g), -DAY_MS)
	// the food runs out with one hungry day left; four more days without food starves it
	advance(&g, T0 + 5 * DAY_MS)
	testing.expect_value(t, g.hunger_ms, DAY_MS)
	advance(&g, T0 + 9 * DAY_MS)
	testing.expect_value(t, g.death, Death.Starved)
	testing.expect_value(t, g.died_ms, T0 + 9 * DAY_MS)
}

@(test)
hungry_fish_can_hold_five_feedings_minus_its_hunger :: proc(t: ^testing.T) {
	// Overfeeding is about the food in the tank, not the condition.
	g := fresh()
	advance(&g, T0 + 2 * DAY_MS)
	for _ in 0 ..< 4 {
		feed(&g, T0 + 2 * DAY_MS)
	}
	testing.expect(t, !doomed(&g))
	feed(&g, T0 + 2 * DAY_MS)
	testing.expect(t, doomed(&g))
}

@(test)
every_condition_band_has_a_description :: proc(t: ^testing.T) {
	g := fresh()
	expect_band :: proc(t: ^testing.T, g: ^Game, c: i64, want: int) {
		g.food_ms, g.hunger_ms = max(c, 0), max(-c, 0)
		testing.expect_value(t, condition_text(g), CONDITION_TEXT[want])
	}
	expect_band(t, &g, -5 * DAY_MS + 1, 0)
	expect_band(t, &g, -4 * DAY_MS, 1)
	expect_band(t, &g, -1, 4)
	expect_band(t, &g, 0, 5)
	expect_band(t, &g, DAY_MS - 1, 5)
	expect_band(t, &g, DAY_MS, 6)
	expect_band(t, &g, 5 * DAY_MS - 1, 9)
}

@(test)
clock_going_backwards_changes_nothing :: proc(t: ^testing.T) {
	g := fresh()
	advance(&g, T0 + DAY_MS)
	before := g
	advance(&g, T0)
	testing.expect_value(t, g, before)
}

@(test)
longest_counts_the_living_fish :: proc(t: ^testing.T) {
	g := fresh()
	advance(&g, T0 + 6 * DAY_MS) // starved at day 5
	get_fish(&g, T0 + 6 * DAY_MS, "Wanda")
	feed(&g, T0 + 6 * DAY_MS)
	testing.expect_value(t, longest_ms(&g, T0 + 7 * DAY_MS), 5 * DAY_MS)
	feed(&g, T0 + 7 * DAY_MS)
	feed(&g, T0 + 8 * DAY_MS)
	testing.expect_value(t, longest_ms(&g, T0 + 12 * DAY_MS), 6 * DAY_MS)
	testing.expect_value(t, fish_count(&g), 2)
}

@(test)
names_are_trimmed_and_capped :: proc(t: ^testing.T) {
	g := fresh()
	testing.expect(t, !set_name(&g, "   "))
	testing.expect_value(t, name_of(&g), "Bubbles")
	set_name(&g, "  Gill  ")
	testing.expect_value(t, name_of(&g), "Gill")
	set_name(&g, "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
	testing.expect_value(t, name_of(&g), "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmn")
	set_name(&g, "🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟")
	testing.expect_value(t, len(name_of(&g)), 40 * 4)
}

@(test)
durations_read_naturally :: proc(t: ^testing.T) {
	testing.expect_value(t, duration_text(0), "0 minutes")
	testing.expect_value(t, duration_text(MINUTE_MS), "1 minute")
	testing.expect_value(t, duration_text(2 * HOUR_MS + 5 * MINUTE_MS), "2 hours, 5 minutes")
	testing.expect_value(t, duration_text(3 * DAY_MS + 7 * HOUR_MS + 12 * MINUTE_MS), "3 days, 7 hours, 12 minutes")
	testing.expect_value(t, duration_text(DAY_MS), "1 day, 0 hours, 0 minutes")
	testing.expect_value(t, ago_text(59_999), "just now")
	testing.expect_value(t, ago_text(3 * HOUR_MS + 12 * MINUTE_MS), "3 hours, 12 minutes ago")
}

@(test)
death_messages_use_the_name_twice :: proc(t: ^testing.T) {
	g := fresh()
	advance(&g, T0 + 5 * DAY_MS + 3 * HOUR_MS + 12 * MINUTE_MS)
	testing.expect_value(t, death_text(&g, T0 + 5 * DAY_MS + 3 * HOUR_MS + 12 * MINUTE_MS),
		"Bubbles starved to death 3 hours, 12 minutes ago. Bubbles waited by the glass for you right up to the end. You had one job.")
	g = fresh()
	for _ in 0 ..< 5 {
		feed(&g, T0)
	}
	advance(&g, T0 + HOUR_MS)
	testing.expect_value(t, death_text(&g, T0 + HOUR_MS),
		"Bubbles died of overeating just now. Bubbles trusted you to know when to stop. You didn't.")
}

@(test)
reset_text_names_what_you_forget :: proc(t: ^testing.T) {
	g := fresh()
	g.starved, g.overfed = 4, 2
	testing.expect_value(t, reset_text(&g),
		"You are about to forget 7 fish. 4 you starved. 2 you overfed. And Bubbles, who is still alive and is about to be flushed. They would not have forgotten you. Forget them anyway?")
	advance(&g, T0 + 6 * DAY_MS)
	testing.expect_value(t, reset_text(&g),
		"You are about to forget 7 fish. 5 you starved. 2 you overfed. They would not have forgotten you. Forget them anyway?")
	g.starved = 0
	g.overfed = 1
	testing.expect_value(t, reset_text(&g),
		"You are about to forget 1 fish. 1 you overfed. They would not have forgotten you. Forget them anyway?")
}
