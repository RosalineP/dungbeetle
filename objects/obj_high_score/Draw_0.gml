// Title.
draw_text_ui(cx, 44, "high scores", 60, c_white, 1, fa_center);

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
    var _col = c_white;
    var _alpha = 1;
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
            if (i == new_rank) _col = COL_HERO;
            _filled = true;
        }
    }

    if (!_filled) _alpha = 0.25;
    draw_text_ui(_x_rank, _y, string(i + 1) + ".", 28, _col, _alpha);
    if (_filled) {
        draw_text_ui(_x_name,  _y, _name, 28, _col, _alpha);
        draw_text_ui(_x_score, _y, string(round(_sc)), 28, _col, _alpha, fa_right);
    } else {
        draw_text_ui(_x_name, _y, "- - -", 28, _col, _alpha);
    }
}

// Footer.
if (entering) {
    draw_text_ui(cx, 672, "new high score! type your name, then press enter", 24, c_white, 1, fa_center);
} else {
    draw_text_ui(cx, 672, "press r to roll again", 24, c_white, 1, fa_center);
}
