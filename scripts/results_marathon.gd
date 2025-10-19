extends Control

@onready var share_button = $ShareButton
@onready var results_display = $ResultsDisplay
@onready var results_title = $ResultsDisplay/Title

class DailyResultsDisplay:
    var title: Label
    var answers: Array[Globals.AnswerAttempt]
    var answer_display_nodes: Array = []

    func _init(results_display_node: Control) -> void:
        title = results_display_node.get_node("Title")
        pass

    func set_title(new_title: String) -> void:
        title.text = new_title


func _ready() -> void:
    Globals.connect("show_results", Callable(self, "_on_show_results"))
    results_display = DailyResultsDisplay.new($ResultsDisplay)
