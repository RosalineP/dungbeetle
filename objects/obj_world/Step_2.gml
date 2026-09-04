if (!instance_exists(obj_player)) exit;

var _dt = dt();
// Zoom follows the same square-root curve as radius: the ball stays the same size on screen.
var _target = clamp(1 / sqrt(obj_player.mass / BASE_MASS), min_zoom, 1);
zoom = lerp(zoom, _target, min(1, 2 * _dt));

var _w = cam_w / zoom;
var _h = cam_h / zoom;
camera_set_view_size(cam, _w, _h);

var _tx = obj_player.x - _w / 2;
var _ty = obj_player.y - _h / 2;
var _cx = lerp(camera_get_view_x(cam), _tx, min(1, 8 * _dt));
var _cy = lerp(camera_get_view_y(cam), _ty, min(1, 8 * _dt));
camera_set_view_pos(cam, _cx, _cy);
