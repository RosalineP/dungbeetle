// Values that a spawner may have set via the instance_create_layer() struct.
// Struct variables are applied BEFORE Create runs, so only default the ones that are missing.
if (!variable_instance_exists(id, "start_mass")) start_mass = BASE_MASS;

growth_yield = 0.8;      // fraction of the prey's mass you actually gain
mouth_scale  = 1.08;     // mouth radius as a multiple of body radius

vx = 0;                  // velocity in px/s. Not "speed"/"direction": those are built-ins.
vy = 0;
facing = 0;              // degrees, direction of travel
roll = 0;                // degrees, ball spin for drawing only
ball_color = c_white;    // tint for spr_ball; children override
beetle_sprite = spr_beetle;

mass = start_mass;

function radius() {
    return mass_to_radius(mass);
}

function set_mass(_m) {
    mass = max(_m, 1);
    var _s = radius() / BASE_RADIUS;
    image_xscale = _s;   // scales the sprite AND its collision mask
    image_yscale = _s;
}

/// Accelerate the velocity toward a target velocity. Children call this from Step.
function steer_toward(_tx, _ty, _rate) {
    var _v = move_toward_2d(vx, vy, _tx, _ty, _rate * dt());
    vx = _v[0];
    vy = _v[1];
}

/// Move, bump into other creatures, stay in the room, update facing and roll.
function apply_motion() {
    var _dt = dt();
    move_and_collide(vx * _dt, vy * _dt, obj_creature);
    var _r = radius();
    x = clamp(x, _r, room_width - _r);
    y = clamp(y, _r, room_height - _r);

    var _spd = point_distance(0, 0, vx, vy);
    if (_spd > 10) {
        facing += angle_difference(point_direction(0, 0, vx, vy), facing) * min(1, 10 * _dt);
    }
    roll -= radtodeg(_spd * _dt / _r);   // arc length / radius = angle
}

/// The mouth: anything inside radius * mouth_scale is a candidate.
function eat_nearby() {
    var _r = radius() * mouth_scale;
    var _list = ds_list_create();

    // Pellets: always edible.
    var _n = collision_circle_list(x, y, _r, obj_pellet, false, true, _list, false);
    for (var i = 0; i < _n; i++) {
        var _p = _list[| i];
        if (instance_exists(_p)) {
            set_mass(mass + _p.mass_value * growth_yield);
            instance_destroy(_p);
        }
    }

    // Other creatures: only if we pass the size rule.
    ds_list_clear(_list);
    _n = collision_circle_list(x, y, _r, obj_creature, false, true, _list, false);
    for (var i = 0; i < _n; i++) {
        var _c = _list[| i];
        if (instance_exists(_c) && _c.id != id && can_eat(mass, _c.mass)) {
            set_mass(mass + _c.mass * growth_yield);
            _c.get_eaten(id);
        }
    }
    ds_list_destroy(_list);
}

/// Called by whoever ate us. obj_player overrides this to report to the world.
function get_eaten(_by) {
    instance_destroy();
}

set_mass(mass);
