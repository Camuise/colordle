extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    #connect to game state changes
    if Globals.has_signal("game_state_changed"):
        Globals.connect("game_state_changed", Callable(self, "_on_game_state_changed"))
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


func _on_game_state_changed(old_state: Globals.GameState, new_state: Globals.GameState) -> void:
    # Define camera positions for each game state
    const camera_positions := {
        Globals.GameState.MAIN_MENU: Vector2(0, 0),
        Globals.GameState.DAILY: Vector2(2560, 0), # to the right
        Globals.GameState.FREEPLAY: Vector2(2560, 720), # to bottom right
        Globals.GameState.RESULTS: Vector2(2560, -720), # to top right
        Globals.GameState.OPTIONS: Vector2(0, 720)  # directly below
    }

    # animate camera to new position and rotate a bit away while leaving starting pos
    if self and new_state in camera_positions:
        var target_position = camera_positions[new_state]
        var away_rotation = deg_to_rad(30.0) if new_state != Globals.GameState.MAIN_MENU else deg_to_rad(-30.0)
        var tween = create_tween()
        # First, rotate away from starting position
        tween.tween_property(self, "rotation", away_rotation, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
        # Then, move to target position and rotate back to final rotation
        tween.tween_property(self, "position", target_position, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
        tween.tween_property(self, "rotation", deg_to_rad(0.1) if new_state != Globals.GameState.MAIN_MENU else deg_to_rad(0.0), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
