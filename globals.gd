extends Node

enum ColorTheme {
    LIGHT,
    DARK
}
@export var theme: ColorTheme = ColorTheme.LIGHT
enum ColordleFormat {
    RGB,
    HEX,
    HSL,
    HSV
}
@export var colordle_format: ColordleFormat = ColordleFormat.HEX
@export var todays_color: Color = _get_todays_color()

signal theme_changed(new_theme: ColorTheme)

func _ready() -> void:
    # Initialize the theme
    set_theme(theme)

func set_theme(new_theme: ColorTheme) -> void:
    if theme != new_theme:
        theme = new_theme
        emit_signal("theme_changed", theme)

func _get_todays_color() -> Color:
    # step 1: get today's date (excluding time) in UNIX
    var _today = Time.get_datetime_dict_from_system()
    var _today_unix = Time.get_unix_time_from_datetime_dict(_today)

    # step 2: use that to seed a random number generator
    var rng = RandomNumberGenerator.new()
    rng.seed = _today_unix

    # step 3: generate a random color
    return Color(rng.randf(), rng.randf(), rng.randf())