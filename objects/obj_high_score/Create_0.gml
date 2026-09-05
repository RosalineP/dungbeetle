// The score for the run that just ended. Zero when the room is reached without
// having played, which just shows the table.
if (!variable_global_exists("last_score")) global.last_score = 0;

ui_font_init();
play_music(snd_menu);

scores = scores_load();
score  = global.last_score;

// Where this run lands, computed against the table before anything is inserted.
// -1 means it did not make the top ten, so there is nothing to name.
rank      = scores_rank(scores, score);
entering  = (rank >= 0);
new_rank  = -1;                 // set once the name is confirmed, to highlight the row
name_max  = 12;
if (entering) keyboard_string = "";   // GameMaker accumulates typing here for us

worm_frame = 0;
worm_fps   = 12;
blink      = 0;

// Layout, all measured from the middle of the room.
cx       = room_width / 2;
list_top = 320;
row_h    = 36;
