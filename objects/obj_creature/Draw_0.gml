var _r = radius();
// Beetle sits behind the ball, pushing. lengthdir_* use GameMaker's degrees (y down).
var _gap = _r + 12 * image_xscale;
var _bx = wrap_coord(x - lengthdir_x(_gap, facing), room_width);
var _by = wrap_coord(y - lengthdir_y(_gap, facing), room_height);
// Everything is drawn again across any seam it straddles, so a creature rolling
// off one edge is visibly arriving at the other.
var _reach = _gap + 24 * image_xscale;
draw_sprite_wrapped(beetle_sprite, _bx, _by, image_xscale, image_yscale, facing, c_white, _reach);
// Ball drawn with its own spin. image_angle stays 0 so the mask never rotates.
draw_sprite_wrapped(sprite_index, x, y, image_xscale, image_yscale, roll, ball_color, _reach);
