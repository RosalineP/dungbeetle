var _r = radius();
// Beetle sits behind the ball, pushing. lengthdir_* use GameMaker's degrees (y down).
var _gap = _r + 12 * image_xscale;
var _bx = x - lengthdir_x(_gap, facing);
var _by = y - lengthdir_y(_gap, facing);
draw_sprite_ext(beetle_sprite, 0, _bx, _by, image_xscale, image_yscale, facing, c_white, 1);
// Ball drawn with its own spin. image_angle stays 0 so the mask never rotates.
draw_sprite_ext(sprite_index, 0, x, y, image_xscale, image_yscale, roll, ball_color, 1);
