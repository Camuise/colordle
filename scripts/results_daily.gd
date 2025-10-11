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
        for answer in range(6):  # max 6 attempts
            var current_answer: Array[ChannelDisplay] = []
            for channel in range(4):  # max 4 channels
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
            print(attempt.channel_grades[i])

        print("Updating display for attempt %d with colors %s" % [attempt_index, channel_values])
        for channel in range(display_row.size()):
            var channel_display = display_row[channel]
            var channel_grade = attempt.channel_grades[channel]
            
            # if is 0, then we know its null so set to 20% opacity
            if attempt.color.a == 0:
                channel_display.grade_color.modulate.a = 0.5
                channel_display.channel_color.color = Color(1, 1, 1, 0.5)
                channel_display.percentage_label.visible = false
                continue
            
            # Make sure elements are visible for valid attempts
            channel_display.grade_color.modulate.a = 1.0
            channel_display.channel_color.modulate.a = 1.0
            channel_display.percentage_label.visible = true
            
            # Update border color based on grade
            channel_display.grade_color.color = Globals.grade_colors[channel_grade.grade]

            # Update color display using proper channel colors
            var channel_color = Globals.get_channel_color_for_display(channel, channel_values)
            channel_display.channel_color.color = channel_color

            # Update percentage label
            channel_display.percentage_label.text = "%.2f%%" % channel_grade.difference


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


func _on_share_requested() -> void:
    # 1. Add title + date
    var share_text: String = "Colordle #%s - %s\n\n" % [Globals._get_puzzle_number(), Globals._get_todays_date()]

    # 2. Add grades (emojis)
    for answer in results_display.answers:
        if answer == Color(0, 0, 0, 0):
            share_text += ""  # Empty attempt
            continue
        for channel_grade in answer.channel_grades:
            match channel_grade.grade:
                Globals.Grade.SAME:
                    share_text += "🟪"  # Purple square
                Globals.Grade.CORRECT:
                    share_text += "🟩"  # Green square
                Globals.Grade.FAR:
                    share_text += "🟧"  # Orange square
                Globals.Grade.NONE:
                    share_text += "⬛"  # Black square
            if channel_grade == answer.channel_grades[-1]:
                share_text += "\n"

    # 3. Copy to clipboard
    DisplayServer.clipboard_set(share_text)
