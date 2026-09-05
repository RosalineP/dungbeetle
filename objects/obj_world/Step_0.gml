// The player vanishing IS the lose condition, however it happened. Detecting it
// here rather than trusting obj_player to report in keeps the game-over screen
// working even if something else destroys the player.
if (instance_exists(obj_player)) {
    last_player_mass = obj_player.mass;
} else if (!game_over) {
    game_over = true;
}

// A collapsed hole is replaced after a pause, so the map keeps rearranging
// itself and the set of exits available to the player keeps changing.
if (!game_over) {
    if (instance_number(obj_hole) < max_holes) {
        hole_timer -= dt();
        if (hole_timer <= 0) {
            spawn_hole();
            hole_timer = hole_refill;
        }
    } else {
        hole_timer = hole_refill;
    }
    exit;
}

if (!frozen) {
    frozen = true;
    instance_deactivate_all(true);   // freeze everything except this controller
}

// Let the panel be read, then hand the run's score to the high score screen.
// The short grace period stops a key that was already down from skipping it.
over_time += dt();
if (over_time > 2.5 || (over_time > 0.6 && keyboard_check_pressed(vk_anykey))) {
    global.last_score = round(last_player_mass);
    instance_activate_all();   // deactivated instances must be woken before a room change
    room_goto(rm_high_score);
}
