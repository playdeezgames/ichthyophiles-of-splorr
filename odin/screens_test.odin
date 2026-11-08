#+build !js
package fish

import "core:strings"
import "core:testing"

@(private = "file")
has_button :: proc(v: ^View, label: string) -> bool {
	for e in v.elems[:v.count] {
		if e.kind == .Button && e.text == label {
			return true
		}
	}
	return false
}

@(private = "file")
has_text :: proc(v: ^View, kind: Elem_Kind, text: string) -> bool {
	for e in v.elems[:v.count] {
		if e.kind == kind && e.text == text {
			return true
		}
	}
	return false
}

@(test)
first_visit_has_no_fish :: proc(t: ^testing.T) {
	a: App
	app_init(&a, 42)
	v := make_view(&a, T0)
	defer free_all(context.temp_allocator)
	testing.expect(t, has_text(&v, .Text, NO_FISH_TEXT))
	testing.expect(t, has_button(&v, "Get a Fish"))
	testing.expect(t, has_button(&v, "How to Play"))
	testing.expect(t, !has_button(&v, "Reset")) // nothing to forget yet
	testing.expect(t, !click(&a, .Feed, T0))
}

@(test)
a_whole_life_through_the_buttons :: proc(t: ^testing.T) {
	a: App
	app_init(&a, 42)
	defer free_all(context.temp_allocator)
	testing.expect(t, click(&a, .Get_Fish, T0))
	v := make_view(&a, T0)
	testing.expect(t, has_button(&v, "Feed"))
	testing.expect(t, has_button(&v, "Reset"))
	testing.expect(t, has_text(&v, .Stat, "Last fed: never"))
	testing.expect(t, has_text(&v, .Stat, "Age: 0 minutes"))
	click(&a, .Feed, T0 + HOUR_MS)
	v = make_view(&a, T0 + 2 * HOUR_MS)
	testing.expect(t, has_text(&v, .Stat, "Last fed: 1 hour, 0 minutes ago"))
	testing.expect(t, has_text(&v, .Stat, "Longest-living fish: 2 hours, 0 minutes"))
	// away for a week: it starved, and the page says so
	app_tick(&a, T0 + 8 * DAY_MS)
	v = make_view(&a, T0 + 8 * DAY_MS)
	testing.expect(t, has_button(&v, "Get a New Fish"))
	testing.expect(t, !has_button(&v, "Feed"))
	testing.expect(t, has_text(&v, .Stat, "Fish starved: 1"))
	testing.expect(t, click(&a, .Get_Fish, T0 + 8 * DAY_MS))
	testing.expect(t, alive(&a.game))
}

@(test)
rename_by_typing_or_at_random :: proc(t: ^testing.T) {
	a: App
	app_init(&a, 7)
	defer free_all(context.temp_allocator)
	click(&a, .Get_Fish, T0)
	first := name_of(&a.game)
	testing.expect(t, click(&a, .Rename, T0))
	v := make_view(&a, T0)
	testing.expect(t, has_text(&v, .Text_Box, first))
	for _ in 0 ..< 50 {
		before := strings.clone(string(a.draft[:a.draft_len]), context.temp_allocator)
		click(&a, .Random_Name, T0)
		testing.expect(t, string(a.draft[:a.draft_len]) != before)
	}
	testing.expect(t, !submit_name(&a, "  ", T0)) // empty: stays open, keeps the name
	testing.expect_value(t, a.screen, Screen.Rename)
	testing.expect_value(t, name_of(&a.game), first)
	testing.expect(t, submit_name(&a, "Wanda", T0))
	testing.expect_value(t, a.screen, Screen.Main)
	testing.expect_value(t, name_of(&a.game), "Wanda")
	click(&a, .Rename, T0)
	click(&a, .Back, T0)
	testing.expect_value(t, name_of(&a.game), "Wanda")
}

@(test)
reset_guilt_trips_then_forgets_everything :: proc(t: ^testing.T) {
	a: App
	app_init(&a, 3)
	defer free_all(context.temp_allocator)
	click(&a, .Get_Fish, T0)
	testing.expect(t, click(&a, .Reset, T0))
	v := make_view(&a, T0)
	testing.expect(t, has_button(&v, "Forget them"))
	testing.expect(t, has_button(&v, "Never mind"))
	click(&a, .Back, T0)
	testing.expect(t, alive(&a.game))
	click(&a, .Reset, T0)
	testing.expect(t, click(&a, .Forget, T0))
	testing.expect(t, !a.game.has_fish)
	testing.expect_value(t, fish_count(&a.game), 0)
	testing.expect_value(t, a.screen, Screen.Main)
}

@(test)
buttons_not_on_screen_do_nothing :: proc(t: ^testing.T) {
	a: App
	app_init(&a, 9)
	click(&a, .How_To_Play, T0)
	testing.expect(t, !click(&a, .Get_Fish, T0))
	testing.expect(t, !click(&a, .Forget, T0))
	testing.expect(t, click(&a, .Back, T0))
	testing.expect(t, !click(&a, .Rename, T0)) // no fish to rename
}

@(test)
element_kinds_match_the_page :: proc(t: ^testing.T) {
	// web/index.html renders kinds by position: title, text, name, stat, button, textbox.
	testing.expect_value(t, int(Elem_Kind.Title), 0)
	testing.expect_value(t, int(Elem_Kind.Text_Box), 5)
	testing.expect_value(t, len(Elem_Kind), 6)
	// web/index.html sends Save_Name through on_submit_name, by this number.
	testing.expect_value(t, int(Action.Save_Name), 7)
}
