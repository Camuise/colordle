extends Control

@onready var share_button = $ShareButton
@onready var results_display_node = $ResultsDisplay

# Wrapper instance (MarathonResultsDisplay) separate from raw node
var results_display


class MarathonResultsDisplay:
    var data: Globals.InfinidleStats
    var _title: Label
    var _bar_graph: Array = []
    var _results_display_node: Control


    func _init(results_display_node: Control) -> void:
        _results_display_node = results_display_node
        _title = results_display_node.get_node("Header/Title")
        for i in range(6):
            _bar_graph.append(results_display_node.get_node("BarGraph/Item%d/ProgressBar" % i))
        pass


    func set_title(new_title: String) -> void:
        _title.text = new_title


    func set_streak(current_streak: int) -> void:
        var streak_display: Label = _results_display_node.get_node("Header/StreakCount")
        streak_display.text = "Streak: %d" % current_streak
        pass


    func set_data(infinidle_stats: Globals.InfinidleStats) -> void:
        data = infinidle_stats
        _update_bar_graph()


    func _update_bar_graph() -> void:
        var max_wins = 1
        for wins in data.win_rows.values():
            if wins > max_wins:
                max_wins = wins
        for i in range(6):
            var bar: ProgressBar = _bar_graph[i]
            var wins = data.win_rows.get(i + 1, 0)
            bar.max_value = max_wins
            bar.value = wins


func _ready() -> void:
    Globals.connect("show_results", Callable(self, "_on_show_results"))
    Globals.connect("infinidle_complete", Callable(self, "_on_infinidle_complete"))
    results_display = MarathonResultsDisplay.new(results_display_node)


func _on_show_results(_puzzle_info: Globals.PuzzleInfo, _game_mode: int, _time_taken: float) -> void:
    results_display.set_title("Colordle ∞ - %s" % Globals.get_todays_date())


func _on_infinidle_complete(infinidle_stats: Globals.InfinidleStats) -> void:
    results_display.set_streak(infinidle_stats.total_wins)
    results_display.set_data(infinidle_stats)
    results_display._update_bar_graph()
