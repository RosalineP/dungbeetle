if (!flying) exit;

var _dt = dt();
fly_t = min(1, fly_t + _dt / fly_time);

// Ease out, so a pellet leaves fast and coasts to a stop. Stepping by the
// change in eased distance rather than setting an absolute position keeps the
// motion correct across a seam.
var _e = 1 - power(1 - fly_t, 3);
var _step = (_e - fly_eased) * fly_dist;
fly_eased = _e;

x = wrap_coord(x + lengthdir_x(_step, fly_dir), WORLD_W);
y = wrap_coord(y + lengthdir_y(_step, fly_dir), WORLD_H);
image_angle += spin * _dt;

if (fly_t >= 1) flying = false;
