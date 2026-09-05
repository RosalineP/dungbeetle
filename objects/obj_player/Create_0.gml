event_inherited();

base_speed = 340;    // px/s at mass 10
accel      = 1600;   // px/s^2 when a key is held
drag       = 1000;   // px/s^2 when no key is held
ball_color = c_white;

// Override: tell the world before disappearing.
// This MUST be a method assignment, not a `function get_eaten()` declaration.
// GML hoists named declarations to the top of the event, so a declaration here
// would be bound before line 1's event_inherited() and then overwritten by
// obj_creature's version, leaving the player with the silent parent behaviour.
get_eaten = function(_by) {
    if (instance_exists(obj_world)) obj_world.on_player_eaten(mass);
    instance_destroy();
};

/// Holes are two-way doors for the player: fall in one, climb out of another
/// that is also big enough. With nowhere to surface, the hole is just scenery.
enter_hole = function(_from) {
    var _exits = [];
    with (obj_hole) {
        if (id != _from && hole_admits(mass, other.mass)) array_push(_exits, id);
    }
    if (array_length(_exits) == 0) return false;

    var _to = _exits[irandom(array_length(_exits) - 1)];
    x = _to.x;
    y = _to.y;
    hole_ignore = _to;   // don't drop straight back through the far end
    return true;
};
