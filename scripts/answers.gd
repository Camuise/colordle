extends VBoxContainer

# region Variables
# =====================================
# STATE VARIABLES
# =====================================
var answers: Array = [
    null,
    null,
    null,
    null,
    null,
    null
]
var puzzle_info: Globals.PuzzleInfo = Globals.PuzzleInfo.new()
var current_row: int = 0
var sound_player: AudioStreamPlayer = null
# endregion


# region Lifecycle
# =====================================
# LIFECYCLE METHODS
# =====================================
func _ready() -> void:
    Globals.connect("color_format_changed", Callable(self, "_on_color_format_changed"))
    _rerender_display()
    puzzle_info.time_started = Time.get_unix_time_from_system()
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
func _on_input_answer_entered(new_answer: Color) -> void:
    print("New answer entered: %s" % new_answer)
    add_answer(new_answer)


func add_answer(new_color: Color) -> void:
    answers[current_row] = new_color
    _update_row(current_row, new_color)
    current_row += 1
    _rerender_display()
    if current_row >= answers.size():
        # runs
        puzzle_completed()


func puzzle_completed() -> void:
    print("All rows filled, moving to results.")
    await get_tree().create_timer(0.5).timeout
    Globals.show_game_results(puzzle_info, Globals.GameState.DAILY)
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
        var diff_to_answer = ColorUtils.color_similarity_percentage(channel_colors[0], channel_colors[1])
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
                total_diff += ColorUtils.color_similarity_percentage(loop_channel_colors[0], loop_channel_colors[1])
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
    # if all answers are null, hide the AnswerContainer and show the NoAnswerContainer
    var is_answers_null: bool = answers.all(func(a): return a == null)
    %AnswerContainer.visible = not is_answers_null
    %NoAnswerContainer.visible = is_answers_null

    for row_index in range(answers.size()):
        _update_row(row_index, answers[row_index])
# endregion


# region Event Handlers
# =====================================
# EVENT HANDLERS & SIGNALS
# =====================================
func _on_color_format_changed(_new_format: Globals.ColorFormat) -> void:
    print_debug("Rerendering display for color format change")
    _rerender_display()
# endregion
