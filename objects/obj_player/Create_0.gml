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
/// The far end is chosen before the drop starts, so the trip is decided at the
/// moment of entry rather than after an animation the player cannot cancel.
anim_exit_to = noone;

enter_hole = function(_from) {
    var _exits = [];
    with (obj_hole) {
        if (usable && id != _from && hole_admits(mass, other.mass)) array_push(_exits, id);
    }
    if (array_length(_exits) == 0) return false;

    anim_exit_to = _exits[irandom(array_length(_exits) - 1)];
    begin_enter_hole(_from);
    return true;
};

/// Method assignment, not a declaration, for the same hoisting reason as
/// get_eaten above.
finish_anim = function() {
    if (anim == ANIM.EXIT) {
        anim = ANIM.NONE;
        anim_hole = noone;
        return;
    }
    // Down one hole, up another. If the far hole collapsed during the fall,
    // surface back where we went in rather than leaving the player nowhere.
    var _to = instance_exists(anim_exit_to) ? anim_exit_to : anim_hole;
    if (instance_exists(_to)) {
        hole_ignore = _to;
        begin_exit_hole(_to);
    } else {
        anim = ANIM.NONE;
        anim_hole = noone;
    }
};
