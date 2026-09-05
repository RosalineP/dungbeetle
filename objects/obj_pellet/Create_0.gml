if (!variable_instance_exists(id, "mass_value")) mass_value = 1;

depth = DEPTH_PELLET;

// Same area-proportional rule as creatures: a mass-4 pellet is twice as wide.
image_xscale = sqrt(mass_value);
image_yscale = sqrt(mass_value);
image_angle  = random(360);
