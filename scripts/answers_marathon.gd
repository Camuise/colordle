extends "res://scripts/answers.gd"

signal new_color_initiated()


func add_answer(new_color: Color) -> void:
    if current_row >= answers.size():
        print("All rows filled, cannot add more answers. Moving on to next color.")
        await get_tree().create_timer(0.5).timeout
        _initiate_new_color()
        return
    answers[current_row] = new_color
    _update_row(current_row, new_color)
    current_row += 1
    _rerender_display()


func _initiate_new_color() -> void:
    answers = Array()
    answers.resize(6)
    answers.fill(null)
    current_row = 0
    _rerender_display()
    emit_signal("new_color_initiated")
