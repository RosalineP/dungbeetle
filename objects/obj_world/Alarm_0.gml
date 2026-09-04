if (instance_number(obj_pellet)   < max_pellets)   spawn_pellet();
if (instance_number(obj_predator) < max_predators) spawn_predator();
alarm[0] = spawn_interval;   // alarms are one-shot; re-arm every time
