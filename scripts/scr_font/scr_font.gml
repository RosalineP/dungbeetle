// UI text. main_font is Avenir Book rasterised at 12 pixels, and it is drawn
// only at whole-number multiples of that size with texture filtering switched
// off. Those two things together are what make it pixellated rather than merely
// small: nearest-neighbour sampling turns every glyph pixel into an exact
// square block, where the default linear filtering would smooth it back into a
// blurry big font.

#macro UI_FONT_BASE 12    // the size main_font was built at
#macro UI_FONT_LINE 22    // its line height at that size

/// Whole-number scale nearest to the size asked for. Fractional scales are what
/// break the illusion: they land glyph pixels between screen pixels.
function ui_scale(_size) {
    return max(1, round(_size / UI_FONT_BASE));
}

/// Width _str would occupy drawn at _size pixels.
function ui_text_width(_str, _size) {
    draw_set_font(main_font);
    return string_width(_str) * ui_scale(_size);
}

/// Draw _str with its top edge at _y. _halign takes the usual fa_* constants.
function draw_text_ui(_x, _y, _str, _size, _col, _alpha = 1, _halign = fa_left) {
    var _s = ui_scale(_size);
    var _filter = gpu_get_texfilter();

    draw_set_font(main_font);
    draw_set_halign(_halign);
    draw_set_valign(fa_top);
    gpu_set_texfilter(false);

    // Whole pixels only, so the block grid lines up with the screen's.
    draw_text_transformed_colour(round(_x), round(_y), _str, _s, _s, 0,
        _col, _col, _col, _col, _alpha);

    gpu_set_texfilter(_filter);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
