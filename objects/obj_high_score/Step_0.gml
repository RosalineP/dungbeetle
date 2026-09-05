var _dt = dt();
worm_frame += worm_fps * _dt;
blink      += _dt;

if (entering) {
    // keyboard_string collects printable characters and handles backspace,
    // so the only work here is keeping it to a sensible length.
    keyboard_string = string_copy(keyboard_string, 1, name_max);

    if (keyboard_check_pressed(vk_enter)) {
        var _name = string_trim(keyboard_string);
        if (_name == "") _name = "ANON";
        scores   = scores_insert(scores, _name, score);
        scores_save(scores);
        new_rank = rank;
        entering = false;
        blink    = 0;
    }
} else if (keyboard_check_pressed(ord("R")) || keyboard_check_pressed(vk_space)) {
    room_goto(rm_arena);
}
