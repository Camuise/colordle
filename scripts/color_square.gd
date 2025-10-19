extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    Globals.todays_color = Globals.get_todays_color()
    self.color = Globals.todays_color


func _on_new_color_initiated() -> void:
    Globals.todays_color = Globals.get_todays_color(true)
    self.color = Globals.todays_color
