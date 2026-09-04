var _h = (keyboard_check(ord("D")) || keyboard_check(vk_right))
       - (keyboard_check(ord("A")) || keyboard_check(vk_left));
var _v = (keyboard_check(ord("S")) || keyboard_check(vk_down))
       - (keyboard_check(ord("W")) || keyboard_check(vk_up));

var _len = point_distance(0, 0, _h, _v);
if (_len > 0) { _h /= _len; _v /= _len; }   // diagonals aren't faster

// Heavier balls are slower, but gently: mass 160 moves at half the speed of mass 10.
var _top = base_speed / power(mass / BASE_MASS, 0.25);
var _rate = (_len > 0) ? accel : drag;
steer_toward(_h * _top, _v * _top, _rate);

event_inherited();   // apply_motion() + eat_nearby()