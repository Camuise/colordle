extends Node

enum ColorTheme {
    LIGHT,
    DARK
}
@export var theme: ColorTheme = ColorTheme.LIGHT
signal theme_changed(new_theme: ColorTheme)

func _ready() -> void:
    # Initialize the theme
    set_theme(theme)

func set_theme(new_theme: ColorTheme) -> void:
    if theme != new_theme:
        theme = new_theme
        emit_signal("theme_changed", theme)