extends "res://scripts/answers.gd"

signal new_color_initiated()

var infinidle_info: Globals.InfinidleStats = Globals.InfinidleStats.new()


func puzzle_completed() -> void:
    print("All rows filled, moving to next color.")
    await get_tree().create_timer(0.5).timeout
    _initiate_new_color()


func _initiate_new_color() -> void:
    # Reset puzzle info with fresh AnswerAttempt objects
    _add_infinidle_win(current_row)
    print("Infinidle stats after win: %s" % str(infinidle_info))
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
