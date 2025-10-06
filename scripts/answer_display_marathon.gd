extends "res://scripts/answers.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


func add_answer(new_color: Color) -> void:
    if current_row >= answers.size():
        print("All rows filled, cannot add more answers.")
        Globals.set_game_state(Globals.GameState.RESULTS)
        return
    answers[current_row] = new_color
    _update_row(current_row, new_color)
    current_row += 1
    _rerender_display()
    if current_row >= answers.size():
        print("All rows filled, moving on to next color.")
        await get_tree().create_timer(0.5).timeout
        answers = Array()
        answers.resize(6)
        answers.fill(null)
        current_row = 0

func initiate_new_color() -> void:
    answers = Array()
    answers.resize(6)
    answers.fill(null)
    current_row = 0
    _rerender_display()
    