extends Control

@onready var share_button = $ShareButton
@onready var results_display_node = $ResultsDisplay

var results_data


class MarathonResultsDisplay:
    var data: Globals.InfinidleStats
    var _title_node: Label
    var title: String:
        set(value):
            _title_node.text = value
        get:
            return _title_node.text
    var _bar_graph: Array = []
    var _results_display_node: Control


    func _init(results_display_node: Control) -> void:
        _results_display_node = results_display_node
        _title_node = results_display_node.get_node("Header/Title")
        for i in range(6):
            _bar_graph.append(results_display_node.get_node("BarGraph/Item%d/ProgressBar" % i))
        pass


    func set_title(new_title: String) -> void:
        _title_node.text = new_title


    func get_streak() -> int:
        return data.total_wins


    func set_data(infinidle_stats: Globals.InfinidleStats) -> void:
        data = infinidle_stats
        _results_display_node.get_node("Header/StreakCount").text = tr("Streak: %d") % data.total_wins
        _update_bar_graph()


    func _update_bar_graph() -> void:
        for i in range(6):
            var bar: ProgressBar = _bar_graph[i]
            var wins = data.win_rows.get(i + 1, 0)
            bar.max_value = data.total_wins
            bar.value = wins


func _ready() -> void:
    Globals.connect("show_results", Callable(self, "_on_show_results"))
    Globals.connect("infinidle_complete", Callable(self, "_on_infinidle_complete"))
    results_data = MarathonResultsDisplay.new(results_display_node)


func _on_show_results(_puzzle_info: Globals.PuzzleInfo, _game_mode: int, _time_taken: float) -> void:
    results_data.set_title(tr("Colordle ∞ - %s") % Globals.get_todays_date())


func _on_infinidle_complete(infinidle_stats: Globals.InfinidleStats) -> void:
    results_data.set_data(infinidle_stats)
    results_data._update_bar_graph()


func _on_share_requested() -> void:
    # 1. Add title + date
    var share_text: String = ("%s, " + tr("Streak: %d") + "\n\n") % [results_data.title, results_data.get_streak()]

    # 2. Generate bar graph with unicode blocks
    var max_wins = 1
    for wins in results_data.data.win_rows.values():
        if wins > max_wins:
            max_wins = wins
    for i in range(6):
        var wins = results_data.data.win_rows.get(i + 1, 0)
        var line: String = "%d: " % (i + 1)
        # map 0 - 10 blocks to max_wins
        var blocks = int(round(float(wins) / float(max_wins) * 10))
        for j in range(10):
            line += "█" if j < blocks else "░"
        # add percentage
        var percent: int = 0
        if results_data.data.total_wins > 0:
            percent = int(round(float(wins) / float(results_data.data.total_wins) * 100.0))
        line += " %d%%" % percent
        line += " (%d)" % wins

        share_text += line + "\n"

    # 3. Copy to clipboard
    DisplayServer.clipboard_set(share_text)
