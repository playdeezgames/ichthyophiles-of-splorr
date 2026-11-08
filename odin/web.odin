#+build js
package fish

import "base:runtime"

// The browser side: hands the view to web/index.html and takes clicks back. Every event
// advances the fish to the page's clock, saves to localStorage, then redraws.

foreign import host "env"

@(default_calling_convention = "contextless")
foreign host {
	// Milliseconds since the epoch (Date.now()).
	now_ms :: proc() -> f64 ---
	// The view: dom_clear, one dom_add per element, then dom_end.
	dom_clear :: proc() ---
	dom_add :: proc(kind: i32, action: i32, ptr: [^]u8, len: i32) ---
	dom_end :: proc() ---
	// Reads the rename box into buf; returns the byte length.
	read_text :: proc(buf: [^]u8, cap: i32) -> i32 ---
	// The save (localStorage). storage_get returns the byte length, or -1 for none.
	storage_get :: proc(buf: [^]u8, cap: i32) -> i32 ---
	storage_set :: proc(ptr: [^]u8, len: i32) ---
}

@(private = "file")
app: App
@(private = "file")
load_buf: [1 << 13]u8
@(private = "file")
text_buf: [NAME_CAP * 2]u8

@(private = "file")
now :: proc() -> i64 {
	return i64(now_ms())
}

main :: proc() {
	t := now()
	app_init(&app, u64(t) ~ 0x9E3779B97F4A7C15)
	n := storage_get(raw_data(load_buf[:]), len(load_buf))
	if n > 0 && int(n) <= len(load_buf) {
		save_decode(&app.game, string(load_buf[:n]))
	}
	settle()
}

// Kept so odin.js does not call _end straight after main; the page has no frame loop.
@(export)
step :: proc(dt: f64, c: runtime.Context) -> bool {
	return true
}

// A button (its Action as a number).
@(export)
on_click :: proc "c" (action: i32) {
	context = runtime.default_context()
	if action > 0 && action < i32(len(Action)) {
		click(&app, Action(action), now())
	}
	settle()
}

// The rename box's Save button or Enter.
@(export)
on_submit_name :: proc "c" () {
	context = runtime.default_context()
	n := read_text(raw_data(text_buf[:]), len(text_buf))
	if n >= 0 && int(n) <= len(text_buf) {
		submit_name(&app, string(text_buf[:n]), now())
	}
	settle()
}

// The page calls this every minute, and when the tab comes back into view.
@(export)
on_tick :: proc "c" () {
	context = runtime.default_context()
	settle()
}

@(private = "file")
settle :: proc() {
	t := now()
	app_tick(&app, t)
	if text, ok := save_encode(&app.game); ok {
		storage_set(raw_data(text), i32(len(text)))
	}
	v := make_view(&app, t)
	dom_clear()
	for e in v.elems[:v.count] {
		dom_add(i32(e.kind), i32(e.action), raw_data(e.text), i32(len(e.text)))
	}
	dom_end()
	free_all(context.temp_allocator)
}
