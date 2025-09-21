extends Node

enum ColorTheme {
    LIGHT,
    DARK
}
@export var theme: ColorTheme = ColorTheme.LIGHT
signal theme_changed(new_theme: ColorTheme)

enum ColorFormat {
    RGB,
    HSV
}
@export var colordle_format: ColorFormat = ColorFormat.HSV
signal color_format_changed(new_format: ColorFormat)

@export var todays_color: Color = _get_todays_color()
enum ColordleResult {
    NONE,
    NOT_GUESSED,
    CORRECT
}
@export var colordle_result: ColordleResult = ColordleResult.NONE

var music_player: AudioStreamPlayer
@export var background_music: AudioStreamPlayer: get = get_background_music


func get_background_music() -> AudioStreamPlayer:
    return music_player


func _ready() -> void:
    # Initialize the theme
    set_theme(theme)

    # Create and configure music player
    music_player = AudioStreamPlayer.new()
    music_player.name = "BackgroundMusic"
    add_child(music_player)

    var music_stream = load("res://sounds/Yoga (Wii Fit).mp3") as AudioStream
    if music_stream:
        music_player.stream = music_stream
        music_player.volume_db = -10  # Adjust volume as needed
        music_player.autoplay = false
        print("Background music loaded successfully")
    else:
        push_error("Failed to load background music stream.")


func set_theme(new_theme: ColorTheme) -> void:
    if theme != new_theme:
        theme = new_theme
        emit_signal("theme_changed", theme)


func set_color_format(new_format: ColorFormat) -> void:
    if colordle_format != new_format:
        colordle_format = new_format
        emit_signal("color_format_changed", colordle_format)


func _get_todays_color() -> Color:
    # step 1: get today's date (excluding time) in UNIX
    var _today: Dictionary = Time.get_datetime_dict_from_system()
    # step 2: strip hour, min, and sec
    _today.erase("hour")
    _today.erase("minute")
    _today.erase("second")

    # step 3: convert back to unix time
    var _today_unix = Time.get_unix_time_from_datetime_dict(_today)

    # step 4: use that to seed a random number generator
    var rng = RandomNumberGenerator.new()
    rng.seed = _today_unix

    # step 5: generate a random color
    var generated_color = Color.from_hsv(rng.randf(), rng.randf(), rng.randf())
    print_debug("Generated HSV color: %s" % generated_color)
    return generated_color
