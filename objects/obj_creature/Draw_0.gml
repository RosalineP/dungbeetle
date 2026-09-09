// Everything drawn here is sized from the APPARENT mass, so a ball wearing
// freshly picked-up pellets grows as it works them in rather than snapping.
var _r = shown_radius();
var _bs = (_r / BASE_RADIUS) * ball_fit;
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
//
// A big ball turns slowly in angular terms, so it lands on the same frame for
// several game frames and the speckles visibly jump between them. Drawing the
// next frame over the top at partial alpha crossfades the two. The silhouette
// is identical either way, so only the pattern blends, and the step reads as
// motion blur instead of a stutter.
var _fn = sprite_get_number(sprite_index);
var _fpos = roll / 360 * _fn;
var _f0 = floor(_fpos);
var _mix = _fpos - _f0;                          // 0..1, correct for negative roll too
_f0 = ((_f0 mod _fn) + _fn) mod _fn;             // GML's mod keeps the sign
draw_sprite_wrapped(sprite_index, _f0, _px, _py - _rise, _bs * _grow, _bs * _grow,
    facing, ball_color, 1, _reach);
if (_mix > 0.02) {
    draw_sprite_wrapped(sprite_index, (_f0 + 1) mod _fn, _px, _py - _rise,
        _bs * _grow, _bs * _grow, facing, ball_color, _mix, _reach);
}

// Pellets stuck to the surface, carried round by the ball's own rotation. Each
// one keeps a fixed point on the sphere; rolling turns that point about the
// axis across our heading, exactly as the baked ball frames do, so a lump rides
// over the top and down out of sight instead of sliding across the face.
var _n = array_length(stuck);
for (var i = 0; i < _n; i++) {
    var _s = stuck[i];
    var _th = degtorad(roll - _s.roll0);
    var _ct = cos(_th), _st = sin(_th);
    var _c = -_s.a * _st + _s.c * _ct;      // height out of the ground
    if (_c <= 0) continue;                  // round the back, hidden by the ball

    var _a = _s.a * _ct + _s.c * _st;       // along our heading
    var _sx = _px + lengthdir_x(_a * _r, facing) + lengthdir_x(_s.b * _r, facing + 90);
    var _sy = _py - _rise
            + lengthdir_y(_a * _r, facing) + lengthdir_y(_s.b * _r, facing + 90);

    // Shrinks away as it is worked in, and flattens as it nears the silhouette.
    var _sink_in = power(1 - _s.t / _s.dur, 0.35);
    var _ps = _s.scale * _grow * _sink_in * (0.72 + 0.28 * _c);
    draw_sprite_wrapped(spr_pellet, 0, wrap_coord(_sx, WORLD_W), wrap_coord(_sy, WORLD_H),
        _ps, _ps, _s.ang, c_white, 1, _reach);
}

// Billy rides on top, straddling the ball's trailing edge. As they go down he
// walks in to the ball's centre so the pair vanish as one thing.
// He is turned to face AWAY from travel: a dung beetle walks backwards, head
// down and hind legs against the ball, pushing it behind him.
var _gap = _r * _bfrac;
var _bx = wrap_coord(_px - lengthdir_x(_gap, facing), WORLD_W);
var _by = wrap_coord(_py - lengthdir_y(_gap, facing), WORLD_H) - _rise;
draw_sprite_wrapped(beetle_sprite, beetle_frame, _bx, _by,
    beetle_fit * _grow, beetle_fit * _grow, facing - 90, c_white, 1, _reach);
