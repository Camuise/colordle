extends VBoxContainer

var answers: Array = [
    null,
    null,
    null,
    null,
    null,
    null
]
var current_row: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    Globals.connect("color_format_changed", Callable(self, "_on_color_format_changed"))
    _rerender_display()

func _on_input_answer_entered(new_answer:Color) -> void:
    print("New answer entered: %s" % new_answer)
    add_answer(new_answer)

func add_answer(new_color: Color) -> void:
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
        var color_display = channel_container.get_node("Border/Color")
        var percentage_label = channel_container.get_node("Percentage")

        # Set opacity to 0% if answer is null, otherwise 100%
        if is_null:
            channel_container.modulate = Color(1, 1, 1, 0)
            continue
        else:
            channel_container.modulate = Color(1, 1, 1, 1)

        # Get display colors for this channel
        var channel_colors = get_channel_colors(channel_index, new_color, Globals.todays_color)
        color_display.color = channel_colors[0]

        # Calculate difference and update label
        var diff_to_answer = calc_color_diff(channel_colors[0], channel_colors[1])
        percentage_label.text = round4(diff_to_answer) + "%"

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
