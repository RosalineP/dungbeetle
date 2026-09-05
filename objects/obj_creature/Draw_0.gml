var _r = radius();
var _bs = image_xscale * ball_fit;   // ball artwork scaled to its world size
var _reach = _r * 3.5;               // covers ball, beetle, shadow and the hop

// Hole transit, as four numbers read off one progress value:
//   grow  ball and beetle swell on the hop, then shrink away down the hole
//   lift  how far off the ground, which the shadow reports rather than the ball
//   bfrac how far out the beetle sits, closing to nothing as they drop together
//   sink  how far the pair have slid onto the mouth
var _grow = 1, _lift = 0, _bfrac = 1, _sink = 0;
var _p = anim_progress();
if (_p > 0) {
    var _hop = 0.45;
    if (_p <= _hop) {
        var _q = _p / _hop;
        _grow = 1 + 0.18 * _q;
        _lift = _q;
    } else {
        var _q = (_p - _hop) / (1 - _hop);
        _grow  = 1.18 * (1 - _q);
        _lift  = 1 - _q;
        _bfrac = 1 - _q;
        _sink  = _q;
    }
}

// Slide onto the mouth as we drop. Measured round the torus, so a hole just
// over a seam is reached the short way like everything else.
var _px = x, _py = y;
if (_sink > 0 && instance_exists(anim_hole)) {
    _px = wrap_coord(x + torus_dx(x, anim_hole.x) * _sink, WORLD_W);
    _py = wrap_coord(y + torus_dy(y, anim_hole.y) * _sink, WORLD_H);
}

// Height is sold by the shadow, not by the ball: the shadow stays on the ground
// and pulls away, shrinking and fading, while the ball is drawn further above it.
var _rise = _r * 0.45 * _lift;
draw_sprite_wrapped(spr_shadow, 0, _px + _r * 0.18, _py + _r * 0.24,
    _bs * 1.05 * (1 - 0.28 * _lift), _bs * 1.05 * (1 - 0.28 * _lift),
    0, c_black, 0.35 * (1 - 0.4 * _lift) * (1 - _sink), _reach);

// The ball's frames are a sphere rolling along the sprite's own +x axis, so
// drawing them turned to `facing` makes the surface travel the way the ball is
// actually going. image_angle stays 0 throughout.
var _frame = roll / 360 * sprite_get_number(sprite_index);
draw_sprite_wrapped(sprite_index, _frame, _px, _py - _rise, _bs * _grow, _bs * _grow,
    facing, ball_color, 1, _reach);

// Billy rides on top, straddling the ball's trailing edge. As they go down he
// walks in to the ball's centre so the pair vanish as one thing.
var _gap = _r * _bfrac;
var _bx = wrap_coord(_px - lengthdir_x(_gap, facing), WORLD_W);
var _by = wrap_coord(_py - lengthdir_y(_gap, facing), WORLD_H) - _rise;
draw_sprite_wrapped(beetle_sprite, beetle_frame, _bx, _by,
    beetle_fit * _grow, beetle_fit * _grow, facing + 90, c_white, 1, _reach);
