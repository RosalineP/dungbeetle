// High score table, persisted between runs.
//
// ini_open() reads and writes in the platform's save area for this game, not
// next to the executable, so the table survives reinstalls of the room and is
// the one piece of state that outlives a session.

#macro SCORE_FILE  "dungacy_scores.ini"
#macro SCORE_SLOTS 10

// Text is white to match the start button. The one accent is the worm's
// lighter orange, used only for the row belonging to the run just played.
#macro COL_HERO make_colour_rgb(0xF8, 0x70, 0x60)

/// The table, best first, as an array of { name, score }. Never longer than
/// SCORE_SLOTS. A missing or empty file simply gives an empty table.
function scores_load() {
    var _list = [];
    ini_open(SCORE_FILE);
    for (var i = 0; i < SCORE_SLOTS; i++) {
        var _n = ini_read_string("scores", "name"  + string(i), "");
        var _s = ini_read_real  ("scores", "score" + string(i), 0);
        if (_n != "" && _s > 0) array_push(_list, { name: _n, score: _s });
    }
    ini_close();
    return _list;
}

function scores_save(_list) {
    ini_open(SCORE_FILE);
    ini_section_delete("scores");   // rewrite wholesale so deletions cannot linger
    var _n = min(array_length(_list), SCORE_SLOTS);
    for (var i = 0; i < _n; i++) {
        ini_write_string("scores", "name"  + string(i), _list[i].name);
        ini_write_real  ("scores", "score" + string(i), _list[i].score);
    }
    ini_close();
}

/// Index _score would occupy in _list, or -1 if it does not make the table.
/// Strictly greater, so a tie leaves the older entry ranked higher.
function scores_rank(_list, _score) {
    if (_score <= 0) return -1;
    var _n = array_length(_list);
    for (var i = 0; i < _n; i++) {
        if (_score > _list[i].score) return i;
    }
    return (_n < SCORE_SLOTS) ? _n : -1;
}

function scores_insert(_list, _name, _score) {
    var _at = scores_rank(_list, _score);
    if (_at < 0) return _list;
    array_insert(_list, _at, { name: _name, score: _score });
    while (array_length(_list) > SCORE_SLOTS) array_pop(_list);
    return _list;
}
