package fish

import "core:fmt"

// The screens as a view model: `make_view` lists what the page shows (headings, paragraphs,
// buttons, a text box) and `click` / `submit_name` run what a button does. Everything is
// testable natively; web.odin only hands the view to the page.

Screen :: enum u8 {
	Main,
	How_To_Play,
	Rename,
	Reset,
}

// The page's element kinds; web/index.html has a table in the same order.
Elem_Kind :: enum u8 {
	Title,
	Text, // a paragraph
	Name, // the fish's name, as a heading
	Stat, // one line of the player's record
	Button,
	Text_Box, // the rename box, holding `text` to start with
}

Action :: enum u8 {
	None,
	Get_Fish,
	Feed,
	Rename,
	How_To_Play,
	Reset,
	Back,
	Save_Name,
	Random_Name,
	Forget,
}

Elem :: struct {
	kind:   Elem_Kind,
	action: Action, // buttons only
	text:   string,
}

MAX_ELEMS :: 24

View :: struct {
	elems: [MAX_ELEMS]Elem,
	count: int,
}

App :: struct {
	game:     Game,
	screen:   Screen,
	rng:      u64, // picks names; seeded by the platform
	// The rename box: its text while the Rename screen is open (a random pick replaces it).
	draft:    [NAME_CAP]u8,
	draft_len: int,
}

app_init :: proc(a: ^App, seed: u64) {
	a^ = {}
	a.rng = seed | 1
}

// Advances the fish to `now`; call before drawing and before every action.
app_tick :: proc(a: ^App, now: i64) {
	advance(&a.game, now)
	if a.screen == .Reset && fish_count(&a.game) == 0 {
		a.screen = .Main
	}
}

@(private = "file")
add :: proc(v: ^View, kind: Elem_Kind, text: string, action := Action.None) {
	if v.count < MAX_ELEMS {
		v.elems[v.count] = Elem{kind, action, text}
		v.count += 1
	}
}

// Strings live in the temp allocator until the next free_all.
make_view :: proc(a: ^App, now: i64) -> (v: View) {
	g := &a.game
	add(&v, .Title, "Ichthyophiles of SPLORR!!")
	switch a.screen {
	case .Main:
		if !g.has_fish {
			add(&v, .Text, NO_FISH_TEXT)
			add(&v, .Button, "Get a Fish", .Get_Fish)
		} else if !alive(g) {
			add(&v, .Name, name_of(g))
			add(&v, .Text, death_text(g, now))
			add(&v, .Button, "Get a New Fish", .Get_Fish)
		} else {
			add(&v, .Name, name_of(g))
			add(&v, .Text, condition_text(g))
			add(&v, .Stat, fmt.tprintf("Age: %s", duration_text(now - g.born_ms)))
			if g.fed_ms == 0 {
				add(&v, .Stat, "Last fed: never")
			} else {
				add(&v, .Stat, fmt.tprintf("Last fed: %s", ago_text(now - g.fed_ms)))
			}
			add(&v, .Button, "Feed", .Feed)
			add(&v, .Button, "Rename", .Rename)
		}
		add(&v, .Stat, fmt.tprintf("Fish overfed: %d", g.overfed))
		add(&v, .Stat, fmt.tprintf("Fish starved: %d", g.starved))
		add(&v, .Stat, fmt.tprintf("Longest-living fish: %s", duration_text(longest_ms(g, now))))
		add(&v, .Button, "How to Play", .How_To_Play)
		if fish_count(g) > 0 {
			add(&v, .Button, "Reset", .Reset)
		}
	case .How_To_Play:
		add(&v, .Text, HOW_TO_PLAY)
		add(&v, .Button, "Back", .Back)
	case .Rename:
		add(&v, .Text, "Name yer fish:")
		add(&v, .Text_Box, string(a.draft[:a.draft_len]))
		add(&v, .Button, "Save", .Save_Name)
		add(&v, .Button, "Random name", .Random_Name)
		add(&v, .Button, "Cancel", .Back)
	case .Reset:
		add(&v, .Text, reset_text(g))
		add(&v, .Button, "Forget them", .Forget)
		add(&v, .Button, "Never mind", .Back)
	}
	return
}

// Runs a button. Returns false for a button the current screen does not show.
click :: proc(a: ^App, action: Action, now: i64) -> bool {
	app_tick(a, now)
	g := &a.game
	switch a.screen {
	case .Main:
		#partial switch action {
		case .Get_Fish:
			return get_fish(g, now, random_name(a, ""))
		case .Feed:
			return feed(g, now)
		case .Rename:
			if !alive(g) {
				return false
			}
			a.draft_len = copy(a.draft[:], name_of(g))
			a.screen = .Rename
			return true
		case .How_To_Play:
			a.screen = .How_To_Play
			return true
		case .Reset:
			if fish_count(g) == 0 {
				return false
			}
			a.screen = .Reset
			return true
		}
	case .How_To_Play:
		if action == .Back {
			a.screen = .Main
			return true
		}
	case .Rename:
		#partial switch action {
		case .Random_Name:
			a.draft_len = copy(a.draft[:], random_name(a, string(a.draft[:a.draft_len])))
			return true
		case .Back:
			a.screen = .Main
			return true
		}
	case .Reset:
		#partial switch action {
		case .Forget:
			reset(g)
			a.screen = .Main
			return true
		case .Back:
			a.screen = .Main
			return true
		}
	}
	return false
}

// The rename box's Save (or Enter). An empty name keeps the old one and the screen open.
submit_name :: proc(a: ^App, text: string, now: i64) -> bool {
	app_tick(a, now)
	if a.screen != .Rename {
		return false
	}
	if !alive(&a.game) {
		a.screen = .Main
		return false
	}
	if !set_name(&a.game, text) {
		return false
	}
	a.screen = .Main
	return true
}

// A random name from the list, never `not` (the current one).
random_name :: proc(a: ^App, not: string) -> string {
	for {
		// xorshift64
		a.rng ~= a.rng << 13
		a.rng ~= a.rng >> 7
		a.rng ~= a.rng << 17
		n := FISH_NAMES[a.rng % len(FISH_NAMES)]
		if n != not {
			return n
		}
	}
}
