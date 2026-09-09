if (!variable_instance_exists(id, "mass_value")) mass_value = 1;

depth = DEPTH_PELLET;

// Same area-proportional rule as creatures: a mass-4 pellet is twice as wide.
rad = pellet_radius(mass_value);
image_xscale = pellet_scale(mass_value);
image_yscale = image_xscale;
image_angle  = random(360);

// Pellets thrown from a burst creature fly outward before settling. A pellet in
// flight cannot be picked up, so a kill visibly scatters instead of being
// swallowed by the killer on the frame it lands.
flying    = false;
fly_dir   = 0;
fly_dist  = 0;
fly_t     = 0;
fly_eased = 0;
fly_time  = PELLET_FLY;
spin      = 0;

/// Collectible? Armed partway through the flight rather than on landing, so a
/// killer rolling forward at speed still sweeps up its own kill.
function can_pick() {
    return !flying || fly_t >= PELLET_ARM;
}

function launch(_dir, _dist) {
    flying = true;
    fly_dir = _dir;
    fly_dist = _dist;
    fly_t = 0;
    fly_eased = 0;
    spin = random_range(-540, 540);
}
