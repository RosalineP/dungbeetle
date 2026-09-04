update_state();

var _dir = 0;
switch (state) {
    case STATE.WANDER:
        if (point_distance(x, y, wander_x, wander_y) < 32) pick_wander_target();
        _dir = point_direction(x, y, wander_x, wander_y);
        break;
    case STATE.CHASE:
        _dir = point_direction(x, y, obj_player.x, obj_player.y);
        break;
    case STATE.FLEE:
        _dir = point_direction(obj_player.x, obj_player.y, x, y);
        break;
}

var _top = move_speed / power(mass / BASE_MASS, 0.25);
steer_toward(lengthdir_x(_top, _dir), lengthdir_y(_top, _dir), steer_rate);

event_inherited();
