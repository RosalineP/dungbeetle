// Holes are measured on the same mass scale as creatures, so a hole of mass m
// is exactly as wide as a creature of mass m. "A hole your size or bigger" is
// then literally what it looks like on screen.
if (!variable_instance_exists(id, "start_mass")) start_mass = BASE_MASS;
if (!variable_instance_exists(id, "life"))       life = 30;   // seconds before it collapses

mass  = start_mass;
depth = DEPTH_HOLE;   // beneath anything that walks over it

function radius() {
    return mass_to_radius(mass);
}

// Scaled off the sprite's own size, so the pit is exactly as wide as the hole
// claims to be. The angle stays at zero: the wall shading has a light direction
// baked into it, and spinning the sprite would spin the light with it.
image_xscale = radius() / (sprite_get_width(spr_hole) / 2);
image_yscale = image_xscale;
image_angle  = 0;

// A hole punches open and pinches shut rather than blinking. It only counts as
// a hole while fully open: half an opening is not something to fall down.
open_time = 0.35;   // seconds to pop open, and again to close
age       = 0;
usable    = false;

/// Drawn scale. Overshoots slightly on the way in for a bit of punch, and eases
/// closed at the end of its life.
function pop_scale() {
    if (age < open_time) {
        var _t = age / open_time;
        var _c1 = 1.70158, _c3 = _c1 + 1;
        return 1 + _c3 * power(_t - 1, 3) + _c1 * power(_t - 1, 2);   // ease out back
    }
    if (life < open_time) {
        var _t = life / open_time;
        return _t * _t * (3 - 2 * _t);                                 // smoothstep out
    }
    return 1;
}

emit_every  = random_range(3.0, 6.0);           // seconds between rivals crawling out
emit_timer  = random_range(0.5, emit_every);    // stagger the first one
guard_delay = 1.0;                              // retry gap when the mouth is blocked

/// True if something sitting on the mouth would swallow a newcomer of mass _m
/// the instant it appeared. A hole that is being camped stays shut, so guarding
/// one denies it rather than farming it for free food.
function mouth_guarded(_m) {
    var _guarded = false;
    var _newborn_r = mass_to_radius(_m);
    with (obj_creature) {
        if (can_eat(mass, _m) && !animating()
        && torus_distance(other.x, other.y, x, y) < radius() * mouth_scale + _newborn_r) {
            _guarded = true;
        }
    }
    return _guarded;
}

/// Rivals that crawl out are never bigger than the hole they came from.
function emit(_m) {
    var _e = instance_create_layer(x, y, LAYER_INSTANCES, obj_enemy, { start_mass: _m });
    _e.hole_ignore = id;   // don't let it fall straight back in
    _e.begin_exit_hole(id);
}
