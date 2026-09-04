// Values that a spawner may have set via the instance_create_layer() struct.
// Struct variables are applied BEFORE Create runs, so only default the ones that are missing.
if (!variable_instance_exists(id, "start_mass")) start_mass = BASE_MASS;

growth_yield = 0.8;      // fraction of the prey's mass you actually gain
mouth_scale  = 1.08;     // mouth radius as a multiple of body radius

vx = 0;                  // velocity in px/s. Not "speed"/"direction": those are built-ins.
vy = 0;
facing = 0;              // degrees, direction of travel
roll = 0;                // degrees, ball spin for drawing only
ball_color = c_white;    // tint for spr_ball; children override
hole_ignore = noone;     // a hole we just came out of, ignored until we are clear of it
beetle_sprite = spr_beetle;

mass = start_mass;

function radius() {
    return mass_to_radius(mass);
}

function set_mass(_m) {
    mass = max(_m, 1);
    var _s = radius() / BASE_RADIUS;
    image_xscale = _s;   // scales the sprite AND its collision mask
    image_yscale = _s;
}

/// Accelerate the velocity toward a target velocity. Children call this from Step.
function steer_toward(_tx, _ty, _rate) {
    var _v = move_toward_2d(vx, vy, _tx, _ty, _rate * dt());
    vx = _v[0];
    vy = _v[1];
}

/// Shove out of anyone we overlap but cannot eat, taking the short way round the seam.
/// move_and_collide is no use here: it knows nothing about wrapping.
function separate() {
    var _r = radius();
    var _sx = 0, _sy = 0;
    with (obj_creature) {
        if (id != other.id
        && !can_eat(mass, other.mass)
        && !can_eat(other.mass, mass)) {
            var _dx = torus_dx(other.x, x);
            var _dy = torus_dy(other.y, y);
            var _d = point_distance(0, 0, _dx, _dy);
            var _min = _r + radius();
            if (_d > 0 && _d < _min) {
                var _push = (_min - _d) * 0.5;
                _sx -= _dx / _d * _push;
                _sy -= _dy / _d * _push;
            }
        }
    }
    x += _sx;
    y += _sy;
}

/// Move, shove, wrap around the arena, update facing and roll.
function apply_motion() {
    var _dt = dt();
    x += vx * _dt;
    y += vy * _dt;
    separate();
    x = wrap_coord(x, room_width);
    y = wrap_coord(y, room_height);

    var _r = radius();
    var _spd = point_distance(0, 0, vx, vy);
    if (_spd > 10) {
        facing += angle_difference(point_direction(0, 0, vx, vy), facing) * min(1, 10 * _dt);
    }
    roll -= radtodeg(_spd * _dt / _r);   // arc length / radius = angle
}

/// The mouth: anything whose body reaches inside radius * mouth_scale is a candidate.
function eat_nearby() {
    var _r = radius() * mouth_scale;

    // Pellets: always edible.
    with (obj_pellet) {
        if (torus_distance(other.x, other.y, x, y) < _r + 8 * image_xscale) {
            other.set_mass(other.mass + mass_value * other.growth_yield);
            instance_destroy();
        }
    }

    // Other creatures: only if we pass the size rule.
    with (obj_creature) {
        if (id != other.id
        && can_eat(other.mass, mass)
        && torus_distance(other.x, other.y, x, y) < _r + radius()) {
            other.set_mass(other.mass + mass * other.growth_yield);
            get_eaten(other.id);
        }
    }
}

/// The hole we are standing in that is big enough to take us, or noone.
/// Children decide what that means: the player falls through, a rival leaves.
function hole_under() {
    var _found = noone;
    with (obj_hole) {
        if (other.hole_ignore != id
        && hole_admits(mass, other.mass)
        && torus_distance(other.x, other.y, x, y) < radius()) {
            _found = id;
        }
    }
    return _found;
}

/// Forget the hole we emerged from once we have rolled clear of it, otherwise
/// anything that comes out of a hole is swallowed by it on the same step.
function update_hole_ignore() {
    if (hole_ignore == noone) return;
    if (!instance_exists(hole_ignore)) { hole_ignore = noone; return; }
    if (torus_distance(x, y, hole_ignore.x, hole_ignore.y) > hole_ignore.radius() + radius()) {
        hole_ignore = noone;
    }
}

/// Called by whoever ate us. obj_player overrides this to report to the world.
function get_eaten(_by) {
    instance_destroy();
}

set_mass(mass);
