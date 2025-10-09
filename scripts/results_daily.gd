extends Control

@onready var share_button = $ShareButton
@onready var results_display = $ResultsDisplay
@onready var results_title = $ResultsDisplay/Title

class ResultsDisplay:
    var title: Label
    var answers: Array[Globals.AnswerAttempt]
    var answer_display_nodes: Array = []

    func _init(results_display_node: Control) -> void:
        title = results_display_node.get_node("Title")
        answers = []
        for i in range(6):
            answers.append(Globals.AnswerAttempt.new())
        # get references to answer display nodes
        for answer in range(6): # max 6 attempts
            var current_answer: Array[ChannelDisplay] = []
            for channel in range(4): # max 4 channels
                var channel_display = ChannelDisplay.new(
                    results_display_node.get_node("AnswerContainer/Answer%d/Channel%d" % [answer, channel])
                )
                current_answer.append(channel_display)
            answer_display_nodes.append(current_answer)

    func set_title(new_title: String) -> void:
        title.text = new_title

    func update_answer_attempt(attempt_index: int, attempt: Globals.AnswerAttempt) -> void:
        if attempt_index < 0 or attempt_index >= answers.size():
            return
        # apply the attempt data onto the correct display node
        answers[attempt_index] = attempt
        var display_row = answer_display_nodes[attempt_index]
        
        # Collect all channel values for this attempt to reconstruct colors
        var channel_values: Array = []
        for i in range(3):  # Only first 3 channels have actual values (RGB or HSV)
            channel_values.append(attempt.channel_grades[i].value)
        
        for channel in range(display_row.size()):
            var channel_display = display_row[channel]
            var channel_grade = attempt.channel_grades[channel]
            # Update border color based on grade
            channel_display.grade_color.color = Globals.grade_colors[channel_grade.grade]
            
            # Update color display using proper channel colors
            var channel_color = _get_channel_colors_for_display(channel, channel_values)
            channel_display.channel_color.color = channel_color
            
            # Update percentage label
            channel_display.percentage_label.text = "%.2f%%" % channel_grade.difference
    
    # Helper function to get channel colors based on stored values and current color format
    func _get_channel_colors_for_display(channel: int, channel_values: Array) -> Color:
        # channel_values should contain [r, g, b] or [h, s, v] depending on current format
        if channel == 3:
            # For the full color channel, reconstruct the full color
            match Globals.colordle_format:
                Globals.ColorFormat.RGB:
                    return Color(channel_values[0], channel_values[1], channel_values[2])
                Globals.ColorFormat.HSV:
                    return Color.from_hsv(channel_values[0], channel_values[1], channel_values[2])
        
        # For individual channels, show the channel-specific color
        match Globals.colordle_format:
            Globals.ColorFormat.RGB:
                match channel:
                    0:
                        return Color(channel_values[0], 0, 0)
                    1:
                        return Color(0, channel_values[1], 0)
                    2:
                        return Color(0, 0, channel_values[2])
            Globals.ColorFormat.HSV:
                match channel:
                    0:
                        return Color.from_hsv(channel_values[0], 1, 1)
                    1:
                        return Color.from_hsv(channel_values[0], channel_values[1], 1)
                    2:
                        return Color.from_hsv(0, 0, channel_values[2])
        
        return Color(0.5, 0.5, 0.5)  # Default gray fallback

class ChannelDisplay:
    var grade_color: ColorRect
    var channel_color: ColorRect
    var percentage_label: Label

    func _init(channel_node: Control) -> void:
        grade_color = channel_node.get_node("Grade")
        channel_color = channel_node.get_node("Grade/Color")
        percentage_label = channel_node.get_node("Closeness")
        pass



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    Globals.connect("show_results", Callable(self, "_on_show_results"))
    results_display = ResultsDisplay.new($ResultsDisplay)


func _on_show_results(puzzle_info: Globals.PuzzleInfo, _game_mode: int, _time_taken: float) -> void:
    results_display.set_title("Colordle #%s - %s" % [Globals._get_puzzle_number(), Globals._get_todays_date()])
    for i in range(puzzle_info.answers.size()):
        results_display.update_answer_attempt(i, puzzle_info.answers[i])
