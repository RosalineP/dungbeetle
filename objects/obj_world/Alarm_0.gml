if (instance_number(obj_pellet) < max_pellets) spawn_pellet();
alarm[0] = spawn_interval;   // alarms are one-shot; re-arm every time
