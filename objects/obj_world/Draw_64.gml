var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

draw_set_colour(c_black);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_text(16, 16, "Ball mass  " + string(round(last_player_mass)));

if (game_over) {
    draw_set_alpha(0.6);
    draw_set_colour(c_black);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(1);

    draw_set_colour(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(_gw / 2, _gh / 2 - 30, "Eaten.");
    draw_text(_gw / 2, _gh / 2,      "Your ball reached mass " + string(round(last_player_mass)) + ".");
    draw_text(_gw / 2, _gh / 2 + 40, "Press R to roll again");

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
