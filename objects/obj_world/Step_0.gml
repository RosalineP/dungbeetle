// The player vanishing IS the lose condition, however it happened. Detecting it
// here rather than trusting obj_player to report in keeps the game-over screen
// working even if something else destroys the player.
if (instance_exists(obj_player)) {
    last_player_mass = obj_player.mass;
} else if (!game_over) {
    game_over = true;
}

if (!game_over) {
    // Outgrowing the arena doubles its area. Several thresholds can fall in one
    // step if a very large meal lands, so this is a while, not an if.
    while (tier < array_length(growth_at) && last_player_mass >= growth_at[tier]) {
        grow_world();
        tier++;
    }

    // A collapsed hole is replaced after a pause, so the map keeps rearranging
    // itself and the set of exits available to the player keeps changing.
    if (instance_number(obj_hole) < max_holes) {
        hole_timer -= dt();
        if (hole_timer <= 0) {
            spawn_hole();
            hole_timer = hole_refill;
        }
    } else {
        hole_timer = hole_refill;
    }
}

// Chase the world's size rather than snapping to it, so each growth reads as a
// pull back rather than a cut.
if (cam_w != WORLD_W) {
    var _k = min(1, zoom_speed * dt());
    cam_w = lerp(cam_w, WORLD_W, _k);
    cam_h = lerp(cam_h, WORLD_H, _k);
    if (abs(WORLD_W - cam_w) < 1) { cam_w = WORLD_W; cam_h = WORLD_H; }
    apply_camera();
}

if (game_over && !frozen) {
    frozen = true;
    instance_deactivate_all(true);   // freeze everything except this controller
}

// Let the panel be read, then hand the run's score to the high score screen.
// The short grace period stops a key that was already down from skipping it.
if (game_over) {
    over_time += dt();
    if (over_time > 2.5 || (over_time > 0.6 && keyboard_check_pressed(vk_anykey))) {
        global.last_score = round(last_player_mass);
        instance_activate_all();   // deactivated instances must be woken before a room change
        room_goto(rm_high_score);
    }
}
