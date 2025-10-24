extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    #connect to game state changes
    if Globals.has_signal("game_state_changed"):
        Globals.connect("game_state_changed", Callable(self, "_on_game_state_changed"))
    pass  # Replace with function body.


func _on_game_state_changed(_old_state: Globals.GameState, new_state: Globals.GameState) -> void:
    # Define camera positions for each game state. defined as screen widths/heights away from origin
    const camera_positions := {
        Globals.GameState.MAIN_MENU: Vector2(0, 0),
        Globals.GameState.DAILY: Vector2(2, 0),  # to the right
        Globals.GameState.MARATHON: Vector2(2, 2),  # to bottom right
        Globals.GameState.RESULTS_DAILY: Vector2(2, 1),  # to top right (daily results)
        Globals.GameState.RESULTS_MARATHON: Vector2(2, 1),  # to top right (marathon results)
        Globals.GameState.OPTIONS: Vector2(0, 2),  # directly below
        Globals.GameState.TUTORIAL: Vector2(0, -2)  # directly above
    }

    var screen_size: Vector2 = get_viewport_rect().size

    # Animate camera to new position and rotate a bit away while leaving starting pos
    if self and new_state in camera_positions:
        var target_position = camera_positions[new_state] * screen_size
        var rotation_direction = -1 if (new_state == Globals.GameState.MAIN_MENU) else 1
        var tween = create_tween()
        tween.tween_property(self, "position", target_position, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
        tween.parallel()
        tween.tween_property(self, "rotation", 0 + deg_to_rad(15) * rotation_direction, 0.75).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
        tween.parallel()
        tween.tween_property(self, "rotation", 0, 0.75).set_delay(0.75).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
