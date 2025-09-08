extends VBoxContainer

var answers: Array[Color] = [
    Color(1, 0, 0),
    Color(0, 1, 0),
    Color(0, 0, 1),
    Color(1, 1, 0),
    Color(1, 0, 1),
    Color(0, 1, 1),
]
var current_row: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

func _on_input_answer_entered(new_answer:Color) -> void:
    add_answer(new_answer)

func add_answer(new_color: Color) -> void:
    answers[current_row] = new_color
    _update_display(current_row, new_color)
    current_row += 1

func calc_color_diff(color1: Color, color2: Color) -> float:
    var color1_lab = ColorUtils.xyz_to_lab(ColorUtils.rgb_to_xyz(color1))
    var color2_lab = ColorUtils.xyz_to_lab(ColorUtils.rgb_to_xyz(color2))
    var delta_e = ColorUtils.calculate_delta_e_76(color1_lab, color2_lab)
    # convert to percentage
    return delta_e

func round4(value: float) -> String:
    # rounds a float to be only 4 characters long.
    var rounded = str(abs(100 - (round(value * 100) / 100)))
    print(rounded)
    # if 3 non-zero chars before dot, drop all decimals
    if rounded.find(".") == 3:
        return rounded.split(".")[0] + "."
    # if 2 non-zero digits before the decimal, drop last decimal
    if rounded.find(".") == 2:
        return rounded.substr(0, 4)
    # only 1 non-zero digit before the decimal, drop padding to left
    return rounded.pad_decimals(2)

func _update_display(row: int, new_color: Color) -> void:
    var node = %AnswerContainer.get_child(row)
    for child in node.get_child_count():
        var channel = node.get_child(child)
        var color_display = channel.get_node("Border/Color")
        var percentage = channel.get_node("Percentage")
        match child:
            0:
                color_display.color = Color(new_color.r, 0, 0)
                var answer_r = Color(new_color.r, 0, 0)
                var correct_r = Color(Globals.todays_color.r, 0, 0)
                var diff_to_answer = calc_color_diff(answer_r, correct_r)
                percentage.text = round4(diff_to_answer) + "%"
            1:
                color_display.color = Color(0, new_color.g, 0)
                var answer_g = Color(0, new_color.g, 0)
                var correct_g = Color(0, Globals.todays_color.g, 0)
                var diff_to_answer = calc_color_diff(answer_g, correct_g)
                percentage.text = round4(diff_to_answer) + "%"
            2:
                color_display.color = Color(0, 0, new_color.b)
                var answer_b = Color(0, 0, new_color.b)
                var correct_b = Color(0, 0, Globals.todays_color.b)
                var diff_to_answer = calc_color_diff(answer_b, correct_b)
                percentage.text = round4(diff_to_answer) + "%"
            3:
                color_display.color = new_color
                var diff_to_answer = calc_color_diff(new_color, Globals.todays_color)
                percentage.text = round4(diff_to_answer) + "%"
