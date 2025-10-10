extends Button

signal on_theme_changed(new_theme)


func _pressed() -> void:
    if Globals.theme == Globals.ColorTheme.LIGHT:
        Globals.set_theme(Globals.ColorTheme.DARK)
        # set image to moon icon
        self.set_button_icon(load("res://assets/images/theme/moon.png"))
    else:
        Globals.set_theme(Globals.ColorTheme.LIGHT)
        # set image to sun icon
        self.set_button_icon(load("res://assets/images/theme/sun.png"))

    emit_signal("on_theme_changed", Globals.theme)
