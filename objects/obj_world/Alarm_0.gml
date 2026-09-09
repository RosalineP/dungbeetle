// Deactivated instances are invisible to instance_number, so once the arena is
// frozen this would read zero pellets and start dropping live ones onto a still
// picture. The top-up stops with the world.
if (!frozen && instance_number(obj_pellet) < pellet_cap()) spawn_pellet();

alarm[0] = spawn_interval;   // alarms are one-shot; re-arm every time
