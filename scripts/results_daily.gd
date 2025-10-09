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
        for channel in range(display_row.size()):
            var channel_display = display_row[channel]
            var channel_grade = attempt.channel_grades[channel]
            # Update border color based on grade
            channel_display.border.color = Globals.grade_colors[channel_grade.grade]
            # Update color display (for simplicity, using grayscale based on value)
            var gray_value = clamp(channel_grade.value / 100.0, 0.0, 1.0)
            channel_display.color_display.color = Color(gray_value, gray_value, gray_value)
            # Update percentage label
            channel_display.percentage_label.text = "%.2f%%" % channel_grade.difference

class ChannelDisplay:
    var border: ColorRect
    var color_display: ColorRect
    var percentage_label: Label

    func _init(channel_node: Control) -> void:
        border = channel_node.get_node("Grade")
        color_display = channel_node.get_node("Grade/Color")
        percentage_label = channel_node.get_node("Closeness")
        pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    Globals.connect("show_results", Callable(self, "_on_show_results"))
    results_display = ResultsDisplay.new($ResultsDisplay)


func _on_show_results(puzzle_info: Globals.PuzzleInfo, game_mode: int, _time_taken: float) -> void:
    results_display.set_title("Colordle #%s - %s" % [Globals._get_puzzle_number(), Globals._get_todays_date()])
    for i in range(puzzle_info.answers.size()):
        results_display.update_answer_attempt(i, puzzle_info.answers[i])
