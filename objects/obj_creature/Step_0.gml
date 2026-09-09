// Stuck pellets keep absorbing whatever else is happening, hole transits included.
update_stuck();

// Mid hop-and-drop: the animation is the only other thing that runs.
if (animating()) {
    update_anim();
    exit;
}

update_hole_ignore();
apply_motion();
eat_nearby();
