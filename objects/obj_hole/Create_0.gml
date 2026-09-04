// Holes are measured on the same mass scale as creatures, so a hole of mass m
// is exactly as wide as a creature of mass m. "A hole your size or bigger" is
// then literally what it looks like on screen.
if (!variable_instance_exists(id, "start_mass")) start_mass = BASE_MASS;
if (!variable_instance_exists(id, "life"))       life = 30;   // seconds before it collapses

mass  = start_mass;
depth = 90;   // under everything that walks over it, above the background layer

function radius() {
    return mass_to_radius(mass);
}

image_xscale = radius() / 8;   // spr_pellet is 16 px wide, so half-width is 8
image_yscale = image_xscale;
image_angle  = random(360);

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
        if (can_eat(mass, _m)
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
}
