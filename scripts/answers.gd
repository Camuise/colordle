extends VBoxContainer

var answers: Array = [
    null,
    null,
    null,
    null,
    null,
    null
]

enum Grade {
    NONE,
    FAR,
    CORRECT,
    SAME,
}



var puzzle_info: Globals.PuzzleInfo = Globals.PuzzleInfo.new()

var current_row: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    Globals.connect("color_format_changed", Callable(self, "_on_color_format_changed"))
    _rerender_display()
    puzzle_info.time_started = Time.get_unix_time_from_system()

enum Result {
    CORRECT,
    FAR,
    CLOSE,
}

var sound_player: AudioStreamPlayer = null


func _play_sound(sound: Result) -> void:
    if not sound_player:
        sound_player = AudioStreamPlayer.new()
        add_child(sound_player)
        sound_player.volume_db = -5  # Adjust volume as needed
    var sound_path = ""
    match sound:
        Result.CORRECT:
            sound_path = "res://assets/sounds/correct.wav"
        Result.FAR:
            sound_path = "res://assets/sounds/far.wav"
        Result.CLOSE:
            sound_path = "res://assets/sounds/close.wav"

    var sound_stream = load(sound_path) as AudioStream
    if sound_stream:
        sound_player.stream = sound_stream
        sound_player.play()
    else:
        push_error("Failed to load sound stream.")


func _on_input_answer_entered(new_answer: Color) -> void:
    print("New answer entered: %s" % new_answer)
    add_answer(new_answer)


func add_answer(new_color: Color) -> void:
    if current_row >= answers.size():
        print("All rows filled, moving to results.")
        await get_tree().create_timer(0.5).timeout
        Globals.show_game_results({
            "time_started": puzzle_info.time_started,
            "time_ended": puzzle_info.time_ended,
            "answers": puzzle_info.answers
        }, Globals.GameState.DAILY)
        return
    answers[current_row] = new_color
    _update_row(current_row, new_color)
    current_row += 1
    _rerender_display()


func calc_color_diff(color1: Color, color2: Color) -> float:
    var color1_lab = ColorUtils.xyz_to_lab(ColorUtils.rgb_to_xyz(color1))
    var color2_lab = ColorUtils.xyz_to_lab(ColorUtils.rgb_to_xyz(color2))
    var delta_e = ColorUtils.calculate_delta_e_76(color1_lab, color2_lab)
    # convert to percentage
    return delta_e


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


# Helper function to get channel colors
func get_channel_colors(channel: int, new_color: Color, correct_color: Color) -> Array:
    if channel == 3:
        return [new_color, correct_color]
    match Globals.colordle_format:
        Globals.ColorFormat.RGB:
            match channel:
                0:
                    return [Color(new_color.r, 0, 0), Color(correct_color.r, 0, 0)]
                1:
                    return [Color(0, new_color.g, 0), Color(0, correct_color.g, 0)]
                2:
                    return [Color(0, 0, new_color.b), Color(0, 0, correct_color.b)]
        Globals.ColorFormat.HSV:
            match channel:
                0:
                    return [Color.from_hsv(new_color.h, 1, 1), Color.from_hsv(correct_color.h, 1, 1)]
                1:
                    return [Color.from_hsv(new_color.h, new_color.s, 1), Color.from_hsv(correct_color.h, correct_color.s, 1)]
                2:
                    return [Color.from_hsv(0, 0, new_color.v), Color.from_hsv(0, 0, correct_color.v)]
    return [Color(), Color()]


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
        var channel_colors = get_channel_colors(channel_index, new_color, Globals.todays_color)
        color_display.color = channel_colors[0]

        # Calculate difference and update label
        var diff_to_answer = calc_color_diff(channel_colors[0], channel_colors[1])
        percentage_label.text = round4(diff_to_answer) + "%"

        print("Row %d, Channel %d: diff = %.2f" % [row, channel_index, diff_to_answer])
        puzzle_info.answers[row].channel_grades[channel_index].difference = diff_to_answer

        # Map difference to border color
        # diff > 50% gray
        # diff < 50% orange
        # diff < 5% green

        if diff_to_answer < 1:
            color_border.color = Color(0.643, 0.369, 0.914)  # Purple
            puzzle_info.answers[row].channel_grades[channel_index].grade = Globals.Grade.SAME
        elif diff_to_answer < 5:
            color_border.color = Color(0, 1, 0)  # Green
            puzzle_info.answers[row].channel_grades[channel_index].grade = Globals.Grade.CORRECT
        elif diff_to_answer > 50:
            color_border.color = Color(0.2, 0.2, 0.2)  # Dark gray
            puzzle_info.answers[row].channel_grades[channel_index].grade = Globals.Grade.NONE
        else:
            color_border.color = Color(1, 0.5, 0)  # Orange
            puzzle_info.answers[row].channel_grades[channel_index].grade = Globals.Grade.FAR


        # Play sound based on overall accuracy (using average of all channels)
        if not is_null and channel_index == 3:
            var total_diff = 0.0
            for i in range(3):
                var loop_channel_colors = get_channel_colors(i, new_color, Globals.todays_color)
                total_diff += calc_color_diff(loop_channel_colors[0], loop_channel_colors[1])
            var avg_diff = total_diff / 3.0
            if avg_diff < 5:
                _play_sound(Result.CORRECT)
            elif avg_diff < 20:
                _play_sound(Result.CLOSE)
            else:
                _play_sound(Result.FAR)

        print("Answer array now: %s" % str(puzzle_info))


func _rerender_display() -> void:
    # if all answers are null, hide the AnswerContainer and show the NoAnswerContainer
    var is_answers_null: bool = answers.all(func(a): return a == null)
    print("Rerendering display, answers null: %s" % is_answers_null)
    %AnswerContainer.visible = not is_answers_null
    %NoAnswerContainer.visible = is_answers_null

    for row_index in range(answers.size()):
        _update_row(row_index, answers[row_index])


func _on_color_format_changed(_new_format: Globals.ColorFormat) -> void:
    print_debug("Rerendering display for color format change")
    _rerender_display()
