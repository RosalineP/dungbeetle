// UI font: Avenir Book, rendered to a glyph sheet so the game's text matches
// the start button's artwork. Chosen by scoring candidate system faces against
// the button's own pixels; Avenir Book was the closest of those installed.
//
// spr_ui_font holds printable ASCII 32..126, one uniform cell per character,
// white on transparent. Each cell has the glyph drawn at its own pen origin, so
// positioning a cell is the same work as positioning a pen.

#macro UI_FONT_PT      48.0    // point size the sheet was rendered at
#macro UI_FONT_MARGIN  6.0     // padding around each cell, in sheet pixels
#macro UI_FONT_ASCENT  48.0
#macro UI_FONT_LINE    1.3750  // line height as a multiple of the drawn size

/// Per-glyph advance widths, indexed by (character code - 32).
function ui_font_init() {
    if (variable_global_exists("ui_adv")) return;
    global.ui_adv = [
        13.344, 13.344, 24.912, 26.688, 26.688, 39.984, 33.792, 12.480,
        12.480, 12.480, 21.312, 31.968, 13.344, 15.984, 13.344, 17.760,
        26.688, 26.688, 26.688, 26.688, 26.688, 26.688, 26.688, 26.688,
        26.688, 26.688, 13.344, 13.344, 31.968, 31.968, 31.968, 23.136,
        38.400, 32.928, 30.240, 33.792, 35.568, 28.464, 26.688, 37.344,
        34.656, 12.672, 23.136, 30.240, 24.000, 42.720, 37.344, 40.032,
        27.552, 40.032, 28.464, 26.688, 27.552, 32.928, 29.328, 45.312,
        30.240, 27.552, 26.688, 12.480, 17.760, 12.480, 31.968, 24.000,
        11.520, 24.912, 29.328, 23.136, 29.328, 26.688, 14.208, 29.328,
        26.688, 11.520, 11.520, 23.136, 11.520, 40.896, 26.688, 28.464,
        29.328, 29.328, 15.936, 20.448, 15.936, 26.688, 23.136, 34.656,
        23.136, 23.136, 20.448, 12.480, 10.656, 12.480, 31.968
    ];
}

/// Index into the glyph sheet, falling back to space for anything unprintable.
function ui_glyph(_ch) {
    var _c = ord(_ch) - 32;
    return (_c < 0 || _c > 94) ? 0 : _c;
}

/// Width _str would occupy drawn at _size pixels.
function ui_text_width(_str, _size) {
    var _w = 0;
    var _n = string_length(_str);
    for (var i = 1; i <= _n; i++) _w += global.ui_adv[ui_glyph(string_char_at(_str, i))];
    return _w * (_size / UI_FONT_PT);
}

/// Draw _str at _size pixels with its top edge at _y. _halign accepts the same
/// fa_* constants as draw_text.
function draw_text_ui(_x, _y, _str, _size, _col, _alpha = 1, _halign = fa_left) {
    var _s = _size / UI_FONT_PT;
    var _px = _x;
    if (_halign == fa_center)     _px -= ui_text_width(_str, _size) / 2;
    else if (_halign == fa_right) _px -= ui_text_width(_str, _size);

    var _cy = _y - UI_FONT_MARGIN * _s;
    var _n = string_length(_str);
    for (var i = 1; i <= _n; i++) {
        var _g = ui_glyph(string_char_at(_str, i));
        if (_g != 0) {
            draw_sprite_ext(spr_ui_font, _g, _px - UI_FONT_MARGIN * _s, _cy,
                _s, _s, 0, _col, _alpha);
        }
        _px += global.ui_adv[_g] * _s;
    }
}
