max_pellets    = 300;
max_predators  = 14;
safe_radius    = 700;               // predators never spawn closer than this to the player
predator_band  = [0.35, 1.8];       // predator mass as a multiple of player mass
spawn_interval = 24;                // steps between top-ups (0.4 s at 60 fps)

min_zoom = 0.18;                    // how far the camera will pull back
zoom     = 1;
cam      = view_camera[0];          // the camera enabled in the Room Editor
cam_w    = camera_get_view_width(cam);
cam_h    = camera_get_view_height(cam);

game_over        = false;
last_player_mass = BASE_MASS;

function spawn_pellet() {
    instance_create_layer(random_range(0, room_width), random_range(0, room_height),
        LAYER_INSTANCES, obj_pellet, { mass_value: random_range(0.5, 2.5) });
}

function spawn_predator() {
    var _px = room_width / 2, _py = room_height / 2;
    if (instance_exists(obj_player)) { _px = obj_player.x; _py = obj_player.y; }
    var _x = random_range(0, room_width), _y = random_range(0, room_height);
    var _tries = 0;
    while (point_distance(_x, _y, _px, _py) < safe_radius && _tries < 20) {
        _x = random_range(0, room_width); _y = random_range(0, room_height); _tries++;
    }
    var _m = last_player_mass * random_range(predator_band[0], predator_band[1]);
    instance_create_layer(_x, _y, LAYER_INSTANCES, obj_predator, { start_mass: _m });
}

/// Called by obj_player.get_eaten().
function on_player_eaten(_final_mass) {
    last_player_mass = _final_mass;
    game_over = true;
    instance_deactivate_all(true);   // freeze everything except this controller
}

// Populate.
instance_create_layer(room_width / 2, room_height / 2, LAYER_INSTANCES, obj_player, { start_mass: BASE_MASS });
repeat (max_pellets)   spawn_pellet();
repeat (max_predators) spawn_predator();
alarm[0] = spawn_interval;
