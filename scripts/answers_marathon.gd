extends "res://scripts/answers.gd"

signal new_color_initiated()

var infinidle_info: Globals.InfinidleStats = Globals.InfinidleStats.new()


func puzzle_completed(successful: bool) -> void:
    var status = "completed" if successful else "failed"
    await get_tree().create_timer(0.5).timeout
    puzzle_info.time_ended = Time.get_unix_time_from_system()
    puzzle_info.successful = successful
    print("Puzzle %s. Time taken: %f seconds. Successful: %s" % [status, puzzle_info.time_ended - puzzle_info.time_started, str(puzzle_info.successful)])
    if successful:
        _add_infinidle_win(current_row)  # current_row is 0-indexed, but win_rows uses 1-6
        _initiate_new_color()
        return
    else:
        Globals.show_game_results(puzzle_info, Globals.GameState.MARATHON)



func _initiate_new_color() -> void:
    puzzle_info.answers.clear()
    for i in range(6):
        puzzle_info.answers.append(Globals.AnswerAttempt.new())
    current_row = 0
    _rerender_display()
    emit_signal("new_color_initiated")


func _add_infinidle_win(row: int) -> void:
    if row < 1 or row > 6:
        push_error("Invalid row number for infinidle win: %d" % row)
        return
    infinidle_info.total_wins += 1
    infinidle_info.win_rows[row] += 1
    print("Infinidle stats updated: %s" % str(infinidle_info))
