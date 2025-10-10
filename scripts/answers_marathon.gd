extends "res://scripts/answers.gd"

signal new_color_initiated()


func puzzle_completed() -> void:
    print("All rows filled, moving to results.")
    await get_tree().create_timer(0.5).timeout
    _initiate_new_color()


func _initiate_new_color() -> void:
    answers = Array()
    answers.resize(6)
    answers.fill(null)
    current_row = 0
    _rerender_display()
    emit_signal("new_color_initiated")
