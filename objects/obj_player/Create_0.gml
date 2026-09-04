event_inherited();

base_speed = 340;    // px/s at mass 10
accel      = 1600;   // px/s^2 when a key is held
drag       = 1000;   // px/s^2 when no key is held
ball_color = c_white;

if (!audio_is_playing(snd_music)) audio_play_sound(snd_music, 100, true);

// Override: tell the world before disappearing.
function get_eaten(_by) {
    if (instance_exists(obj_world)) obj_world.on_player_eaten(mass);
    instance_destroy();
}
