if (instance_exists(obj_player)) last_player_mass = obj_player.mass;

if (game_over && keyboard_check_pressed(ord("R"))) {
    instance_activate_all();   // deactivated instances must be woken before a room change
    room_restart();
}
