// Global rules and helpers. Functions at the top level of a script are global.

/// How many times heavier the eater must be. 1.0 = any edge wins.
#macro EAT_RATIO 1.2
/// Mass at which a creature has BASE_RADIUS (spr_ball is 32 px wide).
#macro BASE_MASS 10
#macro BASE_RADIUS 16
/// Layer name used for every spawned instance.
#macro LAYER_INSTANCES "Instances"

enum STATE { WANDER, CHASE, FLEE }

function can_eat(_eater_mass, _prey_mass) {
    return _eater_mass >= _prey_mass * EAT_RATIO;
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
