var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

draw_text_ui(16, 16, "ball mass  " + string(round(last_player_mass)), 24, c_white);

if (!game_over) exit;

// The dim comes up over the linger, so the arena is still clearly readable
// underneath while the text arrives, and has faded back by the time it settles.
var _dim = 0.55 * min(1, over_time / over_linger);
draw_set_alpha(_dim);
draw_set_colour(c_black);
draw_rectangle(0, 0, _gw, _gh, false);
draw_set_alpha(1);
draw_set_colour(c_white);

// Text fades in quickly: the player needs to know at once, even though the
// scene behind it is still playing.
var _a = min(1, over_time / 0.35);
draw_text_ui(_gw / 2, _gh / 2 - 60, "eaten.", 48, c_white, _a, fa_center);
draw_text_ui(_gw / 2, _gh / 2,
    "your ball reached mass " + string(round(last_player_mass)) + ".", 24, c_white, _a, fa_center);

// Only offered once it will actually do something.
if (over_time > 0.8) {
    draw_text_ui(_gw / 2, _gh / 2 + 48, "press any key", 24, c_white, 0.8, fa_center);
}
