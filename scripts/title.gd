extends Control


func _on_tutorial_button_pressed() -> void:
    Globals.set_game_state(Globals.GameState.TUTORIAL)


func _on_daily_button_pressed() -> void:
    Globals.set_game_state(Globals.GameState.DAILY)


func _on_marathon_button_pressed() -> void:
    Globals.set_game_state(Globals.GameState.MARATHON)


func _on_options_button_pressed() -> void:
    Globals.set_game_state(Globals.GameState.OPTIONS)
