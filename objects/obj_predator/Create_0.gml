event_inherited();

move_speed = 220;    // px/s at mass 10
steer_rate = 900;
sight      = 420;    // px at mass 10; scales with radius

state = STATE.WANDER;
wander_x = x;
wander_y = y;
ball_color = make_colour_rgb(200, 150, 110);   // rivals are visibly different

function pick_wander_target() {
    wander_x = random_range(0, room_width);
    wander_y = random_range(0, room_height);
}

function update_state() {
    if (!instance_exists(obj_player)) { state = STATE.WANDER; return; }
    var _p = obj_player;
    var _d = point_distance(x, y, _p.x, _p.y);
    if (_d > sight * (radius() / BASE_RADIUS))  state = STATE.WANDER;
    else if (can_eat(mass, _p.mass))            state = STATE.CHASE;
    else if (can_eat(_p.mass, mass))            state = STATE.FLEE;
    else                                        state = STATE.WANDER;
}

pick_wander_target();
