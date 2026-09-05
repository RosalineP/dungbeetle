// Mid hop-and-drop: the animation is the only thing that runs.
if (animating()) {
    update_anim();
    exit;
}

update_hole_ignore();
apply_motion();
eat_nearby();
