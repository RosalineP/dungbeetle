event_inherited();

move_speed = 220;    // px/s at mass 10
steer_rate = 900;
sight      = 260;    // px at mass 10; scales with radius

state = STATE.WANDER;
wander_x = x;
wander_y = y;
ball_color = make_colour_rgb(200, 150, 110);   // rivals are visibly different

// Rivals occasionally decide to leave down a hole. The cooldown gates how often
// they even consider it; the chance keeps it rare when they do. The random
// start means one that has just crawled out will not turn round immediately.
hole_target   = noone;
hole_chance   = 0.15;   // probability of committing, per check
hole_recheck  = 1.5;    // seconds between checks
hole_cooldown = random_range(hole_recheck, hole_recheck * 3);

/// Don't walk into an ambush: if something that can eat us is sitting nearer
/// the hole than we are, the exit is guarded and the trip is suicide.
function hole_guarded(_h) {
    if (!instance_exists(obj_player)) return false;
    if (!can_eat(obj_player.mass, mass)) return false;
    return torus_distance(obj_player.x, obj_player.y, _h.x, _h.y)
         < torus_distance(x, y, _h.x, _h.y);
}

function pick_wander_target() {
    wander_x = random_range(0, room_width);
    wander_y = random_range(0, room_height);
}

/// The closest hole in sight that this rival would fit through, or noone.
function nearest_hole_in_sight() {
    var _best = noone;
    var _bestd = sight * (radius() / BASE_RADIUS);
    with (obj_hole) {
        if (hole_admits(mass, other.mass)) {
            var _d = torus_distance(other.x, other.y, x, y);
            if (_d < _bestd) { _bestd = _d; _best = id; }
        }
    }
    return _best;
}

function update_state() {
    hole_cooldown -= dt();

    // Already committed to a hole: keep going until it collapses, or until we
    // no longer fit. A rival that eats on the way can arrive too big for the
    // hole it set out for, so the size rule is re-checked every step, not just
    // at the moment it commits.
    if (state == STATE.HOLE) {
        if (instance_exists(hole_target)
        && hole_admits(hole_target.mass, mass)
        && !hole_guarded(hole_target)) return;
        hole_target = noone;
        state = STATE.WANDER;
    }

    if (instance_exists(obj_player)) {
        var _p = obj_player;
        var _d = torus_distance(x, y, _p.x, _p.y);   // the seam is a shortcut, not a wall
        if (_d > sight * (radius() / BASE_RADIUS))  state = STATE.WANDER;
        else if (can_eat(mass, _p.mass))            state = STATE.CHASE;
        else if (can_eat(_p.mass, mass))            state = STATE.FLEE;
        else                                        state = STATE.WANDER;
    } else {
        state = STATE.WANDER;
    }

    if (hole_cooldown <= 0) {
        hole_cooldown = hole_recheck;
        var _h = nearest_hole_in_sight();
        if (_h != noone && _h != hole_ignore && !hole_guarded(_h) && random(1) < hole_chance) {
            hole_target = _h;
            state = STATE.HOLE;
        }
    }
}

pick_wander_target();
