draw_set_valign(fa_top);

// Title.
draw_set_halign(fa_center);
draw_set_colour(COL_TEXT);
draw_text_transformed(cx, 40, "HIGH SCORES", 4, 4, 0);

// The worm separates the title from the table. Its origin is the top left, so
// it is offset by half its scaled width to sit centred.
var _ws = 0.9;
draw_sprite_ext(spr_worm, worm_frame, cx - (sprite_get_width(spr_worm) * _ws) / 2, 140,
    _ws, _ws, 0, c_white, 1);

// Table. While a name is being typed, a provisional row is shown at the rank
// the run earned, and the saved entries below it shuffle down to make room.
var _x_rank  = cx - 300;
var _x_name  = cx - 230;
var _x_score = cx + 300;

for (var i = 0; i < SCORE_SLOTS; i++) {
    var _y = list_top + i * row_h;
    var _name = "";
    var _sc = 0;
    var _col = COL_TEXT;
    var _filled = false;

    if (entering && i == rank) {
        _name = keyboard_string + ((blink * 2) mod 2 < 1 ? "_" : "");
        _sc = score;
        _col = COL_HERO;
        _filled = true;
    } else {
        var _src = (entering && i > rank) ? i - 1 : i;
        if (_src < array_length(scores)) {
            _name = scores[_src].name;
            _sc = scores[_src].score;
            _col = (i == new_rank) ? COL_HERO : COL_TEXT;
            _filled = true;
        }
    }

    draw_set_colour(_filled ? _col : COL_DIM);
    draw_set_halign(fa_left);
    draw_text_transformed(_x_rank, _y, string(i + 1) + ".", 2, 2, 0);

    if (_filled) {
        draw_text_transformed(_x_name, _y, _name, 2, 2, 0);
        draw_set_halign(fa_right);
        draw_text_transformed(_x_score, _y, string(round(_sc)), 2, 2, 0);
    } else {
        draw_text_transformed(_x_name, _y, "- - -", 2, 2, 0);
    }
}

// Footer.
draw_set_halign(fa_center);
draw_set_colour(COL_TEXT);
if (entering) {
    draw_text_transformed(cx, 680, "New high score! Type your name, then press Enter", 2, 2, 0);
} else {
    draw_text_transformed(cx, 680, "Press R to roll again", 2, 2, 0);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_colour(c_white);
