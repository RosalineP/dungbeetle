update_state();

// Every heading goes the short way round the arena, so a rival will happily
// chase you through a seam and a fleeing one will bolt out the far side.
var _dir = 0;
switch (state) {
    case STATE.WANDER:
        if (torus_distance(x, y, wander_x, wander_y) < 32) pick_wander_target();
        _dir = torus_direction(x, y, wander_x, wander_y);
        break;
    case STATE.CHASE:
        _dir = torus_direction(x, y, obj_player.x, obj_player.y);
        break;
    case STATE.FLEE:
        _dir = torus_direction(obj_player.x, obj_player.y, x, y);
        break;
    case STATE.HOLE:
        _dir = torus_direction(x, y, hole_target.x, hole_target.y);
        break;
}

var _top = move_speed / power(mass / BASE_MASS, 0.25);
steer_toward(lengthdir_x(_top, _dir), lengthdir_y(_top, _dir), steer_rate);

event_inherited();   // update_hole_ignore() + apply_motion() + eat_nearby()

// A rival that reaches a hole it fits through leaves the arena for good.
if (hole_under() != noone) instance_destroy();
