extends Control


func _ready() -> void:
    Globals.connect("show_results", Callable(self, "_on_show_results"))


func _on_show_results(puzzle_info: Globals.PuzzleInfo, _game_mode: int, _time_taken: float) -> void:
    var title: Label
    