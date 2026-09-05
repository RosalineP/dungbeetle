// No steering while dropping down a hole or climbing out of one.
if (animating()) { event_inherited(); exit; }

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
        _dir = wander_bias(torus_direction(x, y, obj_player.x, obj_player.y));
        break;
    case STATE.FLEE:
        _dir = wander_bias(torus_direction(obj_player.x, obj_player.y, x, y));
        break;
    case STATE.HOLE:
        // Deliberately exact: a bent approach makes rivals orbit a small hole
        // instead of dropping into it.
        _dir = torus_direction(x, y, hole_target.x, hole_target.y);
        break;
}

var _top = move_speed * mass_speed_factor(mass);
steer_toward(lengthdir_x(_top, _dir), lengthdir_y(_top, _dir),
    steer_rate * mass_agility_factor(mass));

event_inherited();   // update_hole_ignore() + apply_motion() + eat_nearby()

// A rival that reaches a hole it fits through leaves the arena for good. The
// creature destroys itself at the bottom of the drop, in finish_anim.
var _h = hole_under();
if (_h != noone) begin_enter_hole(_h);
