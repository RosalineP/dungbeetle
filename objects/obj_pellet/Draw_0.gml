// A pellet in flight is briefly larger, which reads as being tossed up and
// landing rather than sliding along the ground.
var _s = image_xscale * (flying ? 1 + 0.45 * (1 - fly_t) : 1);
draw_sprite_wrapped(sprite_index, 0, x, y, _s, _s, image_angle,
    c_white, 1, rad * 2);
