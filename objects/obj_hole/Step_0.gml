var _dt = dt();

// Every hole is temporary. obj_world notices the gap and opens a new one.
life -= _dt;
if (life <= 0) {
    instance_destroy();
    exit;
}

emit_timer -= _dt;
if (emit_timer <= 0) {
    // Roll the newcomer first, so the block test knows exactly how big it is.
    var _m = mass * random_range(0.35, 1.0);
    var _room = instance_exists(obj_world) && instance_number(obj_enemy) < obj_world.max_enemies;

    if (!_room || mouth_guarded(_m)) {
        // Nothing is produced and nothing is banked: a camper waiting on the
        // mouth never collects a backlog of rivals when they finally move off.
        emit_timer = guard_delay;
    } else {
        emit_timer = emit_every;
        emit(_m);
    }
}
