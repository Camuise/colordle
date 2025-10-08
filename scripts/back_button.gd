extends Button


func _on_pressed() -> void:
    Globals.set_game_state(Globals.GameState.MAIN_MENU)
    pass
