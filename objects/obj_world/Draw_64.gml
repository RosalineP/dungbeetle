var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

draw_text_ui(16, 16, "ball mass  " + string(round(last_player_mass)), 24, c_white);

if (game_over) {
    draw_set_alpha(0.6);
    draw_set_colour(c_black);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(1);
    draw_set_colour(c_white);

    draw_text_ui(_gw / 2, _gh / 2 - 60, "eaten.", 48, c_white, 1, fa_center);
    draw_text_ui(_gw / 2, _gh / 2,
        "your ball reached mass " + string(round(last_player_mass)) + ".", 26, c_white, 1, fa_center);
    draw_text_ui(_gw / 2, _gh / 2 + 48, "press any key", 24, c_white, 0.8, fa_center);
}
