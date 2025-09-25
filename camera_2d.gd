extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    #connect to game state changes
    if Globals.has_signal("game_state_changed"):
        Globals.connect("game_state_changed", Callable(self, "_on_game_state_changed"))
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    pass


func _on_game_state_changed(_old_state: Globals.GameState, new_state: Globals.GameState) -> void:
    # Define camera positions for each game state
    const camera_positions := {
        Globals.GameState.MAIN_MENU: Vector2(0, 0),
        Globals.GameState.DAILY: Vector2(2560, 0), # to the right
        Globals.GameState.FREEPLAY: Vector2(2560, 1440), # to bottom right
        Globals.GameState.RESULTS: Vector2(2560, 720), # to top right
        Globals.GameState.OPTIONS: Vector2(0, 1440)  # directly below
    }

    # Animate camera to new position and rotate a bit away while leaving starting pos
    if self and new_state in camera_positions:
        var target_position = camera_positions[new_state]
        var tween = create_tween()
        tween.tween_property(self, "position", target_position, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
