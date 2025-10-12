extends VBoxContainer

# region Variables
# =====================================
# STATE VARIABLES
# =====================================
var puzzle_info: Globals.PuzzleInfo = Globals.PuzzleInfo.new()
var current_row: int = 0
var sound_player: AudioStreamPlayer = null

# Debug state
var debug_mode_active: bool = false
var debug_action: String = ""  # "fail", "pass", or "perfect"
# endregion


# region Lifecycle
# =====================================
# LIFECYCLE METHODS
# =====================================
func _ready() -> void:
    Globals.connect("color_format_changed", Callable(self, "_on_color_format_changed"))
    Globals.connect("game_state_changed", Callable(self, "_on_game_state_changed"))


func _input(event: InputEvent) -> void:
    # Only allow debug shortcuts in debug builds
    if not OS.is_debug_build():
        return

    # Handle debug shortcuts
    if event is InputEventKey and event.pressed and not event.echo:
        # Check if any debug action is pressed
        if Input.is_action_just_pressed("debug_puzzle_fail"):
            debug_mode_active = true
            debug_action = "fail"
            print_debug("Debug mode: Press a number key (1-6) to fail at that row")
            return
        elif Input.is_action_just_pressed("debug_puzzle_pass"):
            debug_mode_active = true
            debug_action = "pass"
            print_debug("Debug mode: Press a number key (1-6) to pass at that row")
            return
        elif Input.is_action_just_pressed("debug_puzzle_perfect"):
            debug_mode_active = true
            debug_action = "perfect"
            print_debug("Debug mode: Press a number key (1-6) to get perfect at that row")
            return

        # If in debug mode, wait for number key
        if debug_mode_active:
            var row_number = -1
            match event.keycode:
                KEY_1: row_number = 1
                KEY_2: row_number = 2
                KEY_3: row_number = 3
                KEY_4: row_number = 4
                KEY_5: row_number = 5
                KEY_6: row_number = 6

            if row_number >= 1 and row_number <= 6:
                _trigger_debug_completion(debug_action, row_number)
                debug_mode_active = false
                debug_action = ""
            else:
                # Cancel debug mode if a non-number key is pressed
                print_debug("Debug mode cancelled")
                debug_mode_active = false
                debug_action = ""
# endregion


# region Audio
# =====================================
# AUDIO SYSTEM
# =====================================
func _play_sound(sound: Globals.Grade) -> void:
    if not sound_player:
        sound_player = AudioStreamPlayer.new()
        add_child(sound_player)
        sound_player.volume_db = -5  # Adjust volume as needed
    var sound_path = ""
    match sound:
        Globals.Grade.SAME:
            sound_path = "res://assets/sounds/correct.wav"
        Globals.Grade.CORRECT:
            sound_path = "res://assets/sounds/close.wav"
        Globals.Grade.FAR:
            sound_path = "res://assets/sounds/far.wav"
        Globals.Grade.NONE:
            sound_path = "res://assets/sounds/far.wav"
        _:
            push_error("Unknown sound grade: %s" % str(sound))

    var sound_stream = load(sound_path) as AudioStream
    if sound_stream:
        sound_player.stream = sound_stream
        sound_player.play()
    else:
        push_error("Failed to load sound stream.")
# endregion


# region Answer Management
# =====================================
# ANSWER MANAGEMENT
# =====================================
func _trigger_debug_completion(action: String, target_row: int) -> void:
    print_debug("Triggering debug completion: %s at row %d" % [action, target_row])

    # Fill rows up to target_row with appropriate colors
    for row in range(target_row):
        var debug_color: Color

        match action:
            "perfect":
                # Perfect match - use exact color
                debug_color = Globals.todays_color
            "pass":
                # Close but not perfect - slightly off from correct color
                var h_offset = randf_range(-0.05, 0.05)
                var s_offset = randf_range(-0.05, 0.05)
                var v_offset = randf_range(-0.05, 0.05)
                debug_color = Color.from_hsv(
                    clamp(Globals.todays_color.h + h_offset, 0.0, 1.0),
                    clamp(Globals.todays_color.s + s_offset, 0.0, 1.0),
                    clamp(Globals.todays_color.v + v_offset, 0.0, 1.0)
                )
            "fail":
                # Random color that's far from correct
                debug_color = Color.from_hsv(randf(), randf(), randf())

        # On the last row for "perfect" and "pass", use the exact color
        if row == target_row - 1 and (action == "perfect" or action == "pass"):
            if action == "perfect":
                debug_color = Globals.todays_color
            else:
                # For "pass", make it close enough to trigger completion
                var similarity_threshold = 96.0  # Just above 95% threshold
                debug_color = _generate_close_color(Globals.todays_color, similarity_threshold)

        puzzle_info.answers[row].color = debug_color
        _update_row(row, debug_color)

    # Update current_row and rerender
    current_row = target_row
    _rerender_display()

    # Trigger completion
    if action == "perfect" or action == "pass":
        puzzle_completed(true)
    else:
        # For fail, need to fill remaining rows with random colors
        for row in range(target_row, puzzle_info.answers.size()):
            var fail_color = Color.from_hsv(randf(), randf(), randf())
            puzzle_info.answers[row].color = fail_color
            _update_row(row, fail_color)
        current_row = puzzle_info.answers.size()
        _rerender_display()
        puzzle_completed(false)


func _generate_close_color(target: Color, similarity: float) -> Color:
    # Generate a color that has the specified similarity percentage to target
    # Higher similarity = closer to target
    var diff_allowed = (100.0 - similarity) / 100.0

    var h_offset = randf_range(-diff_allowed * 0.1, diff_allowed * 0.1)
    var s_offset = randf_range(-diff_allowed * 0.2, diff_allowed * 0.2)
    var v_offset = randf_range(-diff_allowed * 0.2, diff_allowed * 0.2)

    return Color.from_hsv(
        clamp(target.h + h_offset, 0.0, 1.0),
        clamp(target.s + s_offset, 0.0, 1.0),
        clamp(target.v + v_offset, 0.0, 1.0)
    )


func _on_input_answer_entered(new_answer: Color) -> void:
    print("New answer entered: %s" % new_answer)
    add_answer(new_answer)


func add_answer(new_color: Color) -> void:
    if current_row >= puzzle_info.answers.size():
        return  # All rows filled, do nothing
    puzzle_info.answers[current_row].color = new_color
    _update_row(current_row, new_color)
    current_row += 1
    _rerender_display()

    # Check if the color matches exactly
    if ColorUtils.color_similarity_percentage(new_color, Globals.todays_color) > 95.0:
        puzzle_completed(true)
    elif current_row >= puzzle_info.answers.size():
        puzzle_completed(false)


func puzzle_completed(successful: bool) -> void:
    var status = "completed" if successful else "failed"
    print("All rows filled, moving to results.")
    await get_tree().create_timer(0.5).timeout
    Globals.show_game_results(puzzle_info, Globals.GameState.DAILY)
    puzzle_info.time_ended = Time.get_unix_time_from_system()
    puzzle_info.successful = successful
    print("Puzzle %s. Time taken: %f seconds. Successful: %s" % [status, puzzle_info.time_ended - puzzle_info.time_started, str(puzzle_info.successful)])
# endregion


# region Utils
# =====================================
# UTILITY METHODS
# =====================================
# rounds a float to be only 4 characters long.
func round4(value: float) -> String:
    var rounded = str(abs(100 - (round(value * 100) / 100)))
    # if 3 non-zero chars before dot, drop all decimals
    if rounded.find(".") == 3:
        return rounded.split(".")[0] + "."
    # if 2 non-zero digits before the decimal, drop last decimal
    if rounded.find(".") == 2:
        return rounded.substr(0, 4)
    # only 1 non-zero digit before the decimal, drop padding to left
    return rounded.pad_decimals(2)

# endregion


# region Display Updates
# =====================================
# DISPLAY & UI UPDATES
# =====================================
func _update_row(row: int, new_color) -> void:
    var answer_row = %AnswerContainer.get_child(row)
    var is_null = new_color == null
    for channel_index in range(answer_row.get_child_count()):
        var channel_container = answer_row.get_child(channel_index)
        var color_border = channel_container.get_node("Border")
        var color_display = channel_container.get_node("Border/Color")
        var percentage_label = channel_container.get_node("Percentage")

        # Set opacity to 0% if answer is null, otherwise 100%
        if is_null:
            channel_container.modulate = Color(1, 1, 1, 0.5)
            color_display.color = Color(1, 1, 1)
            color_border.color = Color(0, 0, 0)
            percentage_label.text = "    %"
            continue
        else:
            channel_container.modulate = Color(1, 1, 1, 1)

        # Get display colors for this channel
        var channel_colors = Globals.get_channel_colors(channel_index, new_color, Globals.todays_color)
        color_display.color = channel_colors[0]

        # Store the actual channel value for results display
        puzzle_info.answers[row].channel_grades[channel_index].value = Globals.get_channel_value(new_color, channel_index)

        # Calculate difference and update label
        var diff_to_answer = ColorUtils.color_diff_percentage(channel_colors[0], channel_colors[1])
        percentage_label.text = round4(diff_to_answer) + "%"

        puzzle_info.answers[row].channel_grades[channel_index].difference = diff_to_answer

        # Map difference to border color
        if diff_to_answer < Globals.grade_diff_threshold[Globals.Grade.SAME]:
            color_border.color = Color(0.643, 0.369, 0.914)  # Purple
            puzzle_info.answers[row].channel_grades[channel_index].grade = Globals.Grade.SAME
        elif diff_to_answer < Globals.grade_diff_threshold[Globals.Grade.CORRECT]:
            color_border.color = Color(0, 1, 0)  # Green
            puzzle_info.answers[row].channel_grades[channel_index].grade = Globals.Grade.CORRECT
        elif diff_to_answer > Globals.grade_diff_threshold[Globals.Grade.NONE]:
            color_border.color = Color(0.2, 0.2, 0.2)  # Dark gray
            puzzle_info.answers[row].channel_grades[channel_index].grade = Globals.Grade.NONE
        else:
            color_border.color = Color(1, 0.5, 0)  # Orange
            puzzle_info.answers[row].channel_grades[channel_index].grade = Globals.Grade.FAR

        # Play sound based on overall accuracy (using average of all channels)
        if not is_null and channel_index == 3:
            var total_diff = 0.0
            for i in range(3):
                var loop_channel_colors = Globals.get_channel_colors(i, new_color, Globals.todays_color)
                total_diff += ColorUtils.color_diff_percentage(loop_channel_colors[0], loop_channel_colors[1])
            var avg_diff = total_diff / 3.0
            if avg_diff < Globals.grade_diff_threshold[Globals.Grade.SAME]:
                _play_sound(Globals.Grade.SAME)
            elif avg_diff < Globals.grade_diff_threshold[Globals.Grade.CORRECT]:
                _play_sound(Globals.Grade.CORRECT)
            elif avg_diff < Globals.grade_diff_threshold[Globals.Grade.FAR]:
                _play_sound(Globals.Grade.FAR)
            else:
                _play_sound(Globals.Grade.NONE)


func _rerender_display() -> void:
    # if all answers are null (transparent), hide the AnswerContainer and show the NoAnswerContainer
    var is_answers_null: bool = puzzle_info.answers.all(func(a): return a.color.a == 0)
    %AnswerContainer.visible = not is_answers_null
    %NoAnswerContainer.visible = is_answers_null

    for row_index in range(puzzle_info.answers.size()):
        var answer_attempt = puzzle_info.answers[row_index]
        # Pass null if color is transparent (not set), otherwise pass the color
        if answer_attempt.color.a > 0:
            _update_row(row_index, answer_attempt.color)
        else:
            _update_row(row_index, null)
# endregion


# region Event Handlers
# =====================================
# EVENT HANDLERS & SIGNALS
# =====================================
func _on_color_format_changed(_new_format: Globals.ColorFormat) -> void:
    print_debug("Rerendering display for color format change")
    _rerender_display()


func _on_game_state_changed(_old_state: Globals.GameState, new_state: Globals.GameState) -> void:
    if new_state == Globals.GameState.DAILY:
        _rerender_display()
        puzzle_info.time_started = Time.get_unix_time_from_system()
# endregion
