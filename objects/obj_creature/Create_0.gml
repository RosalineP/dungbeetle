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

// Hole transit animation. ENTER is a hop, then beetle and ball converge on the
// hole's mouth and drop out of sight. EXIT is the same thing played backwards.
anim       = ANIM.NONE;
anim_t     = 0;          // 0..1 through the current half of the move
anim_hole  = noone;
anim_time  = 0.42;       // seconds for one half
beetle_sprite = spr_beetle_billy;
beetle_frame  = 0;

// The artwork is authored at whatever size suited the drawing, so each sprite is
// scaled to the world size it should occupy. Reading it off the sprite means
// swapping in new art needs no code change.
// ball_fit is combined with image_xscale, so the ball grows with mass.
// beetle_fit is used on its own: Billy is always the same size on screen.
ball_fit   = BASE_RADIUS / (sprite_get_width(spr_ball) / 2);
beetle_fit = 38 / sprite_get_width(beetle_sprite);   // Billy's width in pixels

depth = DEPTH_CREATURE;

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

function animating() {
    return anim != ANIM.NONE;
}

function begin_enter_hole(_h) {
    anim = ANIM.ENTER; anim_t = 0; anim_hole = _h;
    vx = 0; vy = 0;
}

function begin_exit_hole(_h) {
    anim = ANIM.EXIT; anim_t = 0; anim_hole = _h;
    vx = 0; vy = 0;
    x = _h.x; y = _h.y;
}

/// Where the animation has got to, as 0 (fully above ground, normal) through
/// 1 (gone, at the mouth). EXIT is simply ENTER read backwards.
function anim_progress() {
    if (anim == ANIM.ENTER) return anim_t;
    if (anim == ANIM.EXIT)  return 1 - anim_t;
    return 0;
}

function update_anim() {
    anim_t += dt() / anim_time;
    if (anim_t < 1) return;
    anim_t = 1;
    finish_anim();
}

/// Reaching the bottom of an ENTER means leaving the arena. Children that have
/// somewhere to come back up override this.
function finish_anim() {
    if (anim == ANIM.EXIT) {
        anim = ANIM.NONE;
        anim_hole = noone;
        return;
    }
    instance_destroy();
}

/// Shove out of anyone we overlap but cannot eat, taking the short way round the seam.
/// move_and_collide is no use here: it knows nothing about wrapping.
function separate() {
    var _r = radius();
    var _sx = 0, _sy = 0;
    with (obj_creature) {
        if (id != other.id
        && !animating() && !other.animating()
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
    x = wrap_coord(x, WORLD_W);
    y = wrap_coord(y, WORLD_H);

    var _r = radius();
    var _spd = point_distance(0, 0, vx, vy);
    if (_spd > 10) {
        // Heavy balls swing round slowly, matching how sluggishly the velocity
        // itself is allowed to turn.
        var _turn = 10 * mass_agility_factor(mass);
        facing += angle_difference(point_direction(0, 0, vx, vy), facing) * min(1, _turn * _dt);
    }

    // Roll by the distance travelled ALONG the way we are pointing, not by raw
    // speed. Backing up then unwinds the spin instead of winding it further the
    // same way, which is what sells the ball as rolling rather than spinning.
    var _fwd = vx * lengthdir_x(1, facing) + vy * lengthdir_y(1, facing);
    roll += radtodeg(_fwd * _dt / _r);   // arc length / radius = angle
    beetle_frame += _spd * _dt * 0.05;   // Billy scuttles faster the faster we go
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
        && !animating()
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
        if (usable
        && other.hole_ignore != id
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
