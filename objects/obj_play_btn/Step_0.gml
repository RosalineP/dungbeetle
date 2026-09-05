hovering = position_meeting(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), id);

if (hovering && mouse_check_button_pressed(mb_left)) {
	clicked = true;
} 

if (mouse_check_button_released(mb_left)) {
	clicked = false;

	if (hovering) {
		// to implement, this starts the game
	}
} 

if (clicked) {
	sprite_index = asset_get_index("spr_play_pressed");
} else if (hovering) {
	sprite_index = asset_get_index("spr_play_hover");
} else {
	sprite_index = asset_get_index("spr_play");
}
