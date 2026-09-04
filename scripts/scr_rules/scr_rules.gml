// Global rules and helpers. Functions at the top level of a script are global.

/// How many times heavier the eater must be. 1.0 = any edge wins.
#macro EAT_RATIO 1.2
/// Mass at which a creature has BASE_RADIUS (spr_ball is 32 px wide).
#macro BASE_MASS 10
#macro BASE_RADIUS 16
/// Layer name used for every spawned instance.
#macro LAYER_INSTANCES "Instances"

enum STATE { WANDER, CHASE, FLEE, HOLE }

function can_eat(_eater_mass, _prey_mass) {
    return _eater_mass >= _prey_mass * EAT_RATIO;
}

/// A hole takes anything no bigger than itself. Holes are sized on the same
/// mass scale as creatures, so this is exactly what it looks like on screen.
function hole_admits(_hole_mass, _body_mass) {
    return _hole_mass >= _body_mass;
}

function mass_to_radius(_mass) {
    return BASE_RADIUS * sqrt(_mass / BASE_MASS);
}

/// Seconds since the last step. Movement is in pixels per second everywhere.
function dt() {
    return delta_time / 1000000;
}

/// Move (_vx, _vy) toward (_tx, _ty) by at most _step. Returns [vx, vy].
function move_toward_2d(_vx, _vy, _tx, _ty, _step) {
    var _dx = _tx - _vx;
    var _dy = _ty - _vy;
    var _d = point_distance(0, 0, _dx, _dy);
    if (_d <= _step || _d == 0) return [_tx, _ty];
    return [_vx + _dx / _d * _step, _vy + _dy / _d * _step];
}

// --- Torus geometry -------------------------------------------------------
// The arena wraps on both axes, so nothing may use raw coordinate differences:
// two points either side of a seam are neighbours, not opposites.

/// Fold a coordinate back into [0, _size).
function wrap_coord(_v, _size) {
    return ((_v mod _size) + _size) mod _size;
}

/// Shortest signed offset from _a to _b along an axis that wraps every _size.
function torus_delta(_a, _b, _size) {
    var _d = (_b - _a) mod _size;
    if (_d >  _size / 2) _d -= _size;
    if (_d < -_size / 2) _d += _size;
    return _d;
}

function torus_dx(_x1, _x2) { return torus_delta(_x1, _x2, room_width); }
function torus_dy(_y1, _y2) { return torus_delta(_y1, _y2, room_height); }

/// Distance through the seam if that is shorter.
function torus_distance(_x1, _y1, _x2, _y2) {
    return point_distance(0, 0, torus_dx(_x1, _x2), torus_dy(_y1, _y2));
}

/// Direction from point 1 to point 2, taking the short way round.
function torus_direction(_x1, _y1, _x2, _y2) {
    return point_direction(0, 0, torus_dx(_x1, _x2), torus_dy(_y1, _y2));
}

/// Draw a sprite, repeating it across any seam it overlaps.
/// _reach is how far the drawing extends from (_px, _py).
function draw_sprite_wrapped(_spr, _px, _py, _xs, _ys, _ang, _col, _reach) {
    var _ox = 0, _oy = 0;
    if (_px < _reach)                _ox =  room_width;
    else if (_px > room_width - _reach)  _ox = -room_width;
    if (_py < _reach)                _oy =  room_height;
    else if (_py > room_height - _reach) _oy = -room_height;

    draw_sprite_ext(_spr, 0, _px, _py, _xs, _ys, _ang, _col, 1);
    if (_ox != 0) draw_sprite_ext(_spr, 0, _px + _ox, _py, _xs, _ys, _ang, _col, 1);
    if (_oy != 0) draw_sprite_ext(_spr, 0, _px, _py + _oy, _xs, _ys, _ang, _col, 1);
    if (_ox != 0 && _oy != 0) draw_sprite_ext(_spr, 0, _px + _ox, _py + _oy, _xs, _ys, _ang, _col, 1);
}
