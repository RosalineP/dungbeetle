// No steering while dropping down a hole or climbing out of one.
if (animating()) { event_inherited(); exit; }

var _h = (keyboard_check(ord("D")) || keyboard_check(vk_right))
       - (keyboard_check(ord("A")) || keyboard_check(vk_left));
var _v = (keyboard_check(ord("S")) || keyboard_check(vk_down))
       - (keyboard_check(ord("W")) || keyboard_check(vk_up));

var _len = point_distance(0, 0, _h, _v);
if (_len > 0) { _h /= _len; _v /= _len; }   // diagonals aren't faster

// Heavier balls roll slightly faster but take far longer to get there, and to
// stop: the drag term is scaled the same way, so they coast.
var _top = base_speed * mass_speed_factor(mass);
var _rate = ((_len > 0) ? accel : drag) * mass_agility_factor(mass);
steer_toward(_h * _top, _v * _top, _rate);

event_inherited();   // update_hole_ignore() + apply_motion() + eat_nearby()

var _hole = hole_under();
if (_hole != noone) enter_hole(_hole);