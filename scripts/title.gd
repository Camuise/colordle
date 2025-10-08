extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


func _on_daily_button_pressed() -> void:
    Globals.set_game_state(Globals.GameState.DAILY)
    pass  # Replace with function body.


func _on_free_play_button_pressed() -> void:
    Globals.set_game_state(Globals.GameState.MARATHON)
    pass  # Replace with function body.


func _on_options_button_pressed() -> void:
    Globals.set_game_state(Globals.GameState.OPTIONS)
    pass  # Replace with function body.
