play_music(snd_music);

// The world starts one screen across and doubles in area each time the player
// crosses a threshold. Set before anything else: every spawn below measures
// itself against the world, not the room.
global.world_w = WORLD_W0;
global.world_h = WORLD_H0;

growth_at = [50, 100, 200, 400, 800, 1600, 3200];   // player mass, in order
tier      = 0;                                      // how many we have crossed

base_pellets = 60;
base_enemies = 6;
base_holes   = 4;
base_safe    = 260;                 // nothing spawns this close to the player

/// Populations track the world's width, not its area. Keeping the density
/// constant would mean thousands of pellets at the top tier, and every creature
/// tests every pellet every step.
function refresh_limits() {
    var _lin = WORLD_W / WORLD_W0;
    max_pellets = min(360, round(base_pellets * _lin));
    max_enemies = min(20,  round(base_enemies * _lin));
    max_holes   = min(14,  round(base_holes   * _lin));
    safe_radius = base_safe * _lin;
}
refresh_limits();

enemy_band     = [0.35, 1.8];       // rival mass as a multiple of player mass
hole_band      = [0.6, 2.5];        // hole mass as a multiple of player mass
hole_life      = [18, 40];          // seconds a hole lasts before collapsing
hole_refill    = 3.0;               // seconds before a collapsed hole is replaced
spawn_interval = 24;                // steps between pellet top-ups (0.4 s at 60 fps)

// The camera always frames the whole world, so it is the world's size that
// zooms. cam_w chases the target rather than snapping, which turns each growth
// into a visible pull back.
cam        = view_camera[0];
cam_w      = WORLD_W;
cam_h      = WORLD_H;
zoom_speed = 1.6;                   // fraction of the remaining gap per second
apply_camera();

game_over        = false;
frozen           = false;
over_time        = 0;      // seconds since death, before handing over to the score screen
last_player_mass = BASE_MASS;
hole_timer       = 0;

function apply_camera() {
    camera_set_view_size(cam, cam_w, cam_h);
    // Centred, so a zoom that has not caught up yet shows the middle of the
    // world rather than a corner, and never straddles a seam.
    camera_set_view_pos(cam, (WORLD_W - cam_w) / 2, (WORLD_H - cam_h) / 2);
}

/// Double the arena's area and shift everything so the old world ends up
/// centred in the new one, rather than pinned to a corner with all the fresh
/// space on two sides.
function grow_world() {
    var _ow = WORLD_W, _oh = WORLD_H;
    global.world_w = _ow * WORLD_GROWTH;
    global.world_h = _oh * WORLD_GROWTH;

    var _dx = (WORLD_W - _ow) / 2;
    var _dy = (WORLD_H - _oh) / 2;
    with (obj_creature) { x += _dx; y += _dy; }
    with (obj_pellet)   { x += _dx; y += _dy; }
    with (obj_hole)     { x += _dx; y += _dy; }
    with (obj_enemy)    { wander_x += _dx; wander_y += _dy; }

    refresh_limits();
}

/// Somewhere at least safe_radius from the player, measured round the torus so
/// a "safe" spot cannot turn out to be one step through the nearest seam.
function spawn_point() {
    var _px = WORLD_W / 2, _py = WORLD_H / 2;
    if (instance_exists(obj_player)) { _px = obj_player.x; _py = obj_player.y; }
    var _x = random_range(0, WORLD_W), _y = random_range(0, WORLD_H);
    var _tries = 0;
    while (torus_distance(_x, _y, _px, _py) < safe_radius && _tries < 20) {
        _x = random_range(0, WORLD_W); _y = random_range(0, WORLD_H); _tries++;
    }
    return [_x, _y];
}

function spawn_pellet() {
    instance_create_layer(random_range(0, WORLD_W), random_range(0, WORLD_H),
        LAYER_INSTANCES, obj_pellet, { mass_value: random_range(0.5, 2.5) });
}

/// Holes are sized against the player, so there is usually one they can enter
/// and one big enough to be pouring out something dangerous.
function spawn_hole() {
    var _p = spawn_point();
    instance_create_layer(_p[0], _p[1], LAYER_INSTANCES, obj_hole, {
        start_mass: last_player_mass * random_range(hole_band[0], hole_band[1]),
        life:       random_range(hole_life[0], hole_life[1]),
    });
}

/// Called by obj_player.get_eaten(), from inside a loop over creatures.
/// Only raises the flag; Step does the freezing once that loop has finished.
function on_player_eaten(_final_mass) {
    last_player_mass = _final_mass;
    game_over = true;
}

// Populate. Rivals are not placed directly: they crawl out of holes.
instance_create_layer(WORLD_W / 2, WORLD_H / 2, LAYER_INSTANCES, obj_player, { start_mass: BASE_MASS });
repeat (max_pellets) spawn_pellet();
repeat (max_holes)   spawn_hole();
alarm[0] = spawn_interval;
