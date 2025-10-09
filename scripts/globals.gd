extends Node

# region Theme System
# ============================================================================
# THEME SYSTEM
# ============================================================================
enum ColorTheme {
    LIGHT,
    DARK
}
@export var theme: ColorTheme = ColorTheme.LIGHT
signal theme_changed(new_theme: ColorTheme)


func set_theme(new_theme: ColorTheme) -> void:
    if theme != new_theme:
        theme = new_theme
        emit_signal("theme_changed", theme)
# endregion

# region Game State
# ============================================================================
# GAME STATE MANAGEMENT
# ============================================================================
enum GameState {
    MAIN_MENU,
    DAILY,
    MARATHON,
    RESULTS,
    OPTIONS
}
@export var game_state: GameState = GameState.MAIN_MENU
signal game_state_changed(new_state: GameState)
signal show_results(puzzle_info: PuzzleInfo, game_mode: GameState, time_taken: float)


func set_game_state(new_state: GameState) -> void:
    if game_state == new_state:
        return

    var old_state = game_state
    game_state = new_state
    emit_signal("game_state_changed", old_state, game_state)


func show_game_results(puzzle_info: PuzzleInfo, game_mode: GameState) -> void:
    assert(game_mode in [GameState.DAILY, GameState.MARATHON], "game_mode must be DAILY or MARATHON")
    set_game_state(GameState.RESULTS)
    var time_taken = puzzle_info.time_ended - puzzle_info.time_started
    emit_signal("show_results", puzzle_info, game_mode, time_taken)
# endregion

# region Format & Puzzle
# ============================================================================
# COLORDLE PUZZLE FORMAT + TODAY'S COLOR
# ============================================================================
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


func set_color_format(new_format: ColorFormat) -> void:
    if colordle_format != new_format:
        colordle_format = new_format
        emit_signal("color_format_changed", colordle_format)


func _get_todays_color(time: bool = false) -> Color:
    # step 1: get today's date (excluding time) in UNIX
    var _today: Dictionary = Time.get_datetime_dict_from_system()

    if !time:
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


func _get_puzzle_number() -> int:
    # Define the start date (January 1, 2023)
    var start_date = Time.get_unix_time_from_datetime_dict({
        "year": 2025,
        "month": 8,
        "day": 18,
        "hour": 0,
        "minute": 0,
        "second": 0
    })

    # Get today's date at midnight
    var today = Time.get_datetime_dict_from_system()
    var today_unix = Time.get_unix_time_from_datetime_dict({
        "year": today.year,
        "month": today.month,
        "day": today.day,
        "hour": 0,
        "minute": 0,
        "second": 0
    })

    # Calculate days difference
    var days_diff = int((today_unix - start_date) / 86400.0)  # 86400 seconds in a day
    return days_diff + 1  # +1 to make it 1-indexed


func _get_todays_date() -> String:
    var today = Time.get_datetime_dict_from_system()
    return "%02d/%02d" % [today.month, today.day]
# endregion

# region Grading
# ============================================================================
# GRADING SYSTEM
# ============================================================================
enum Grade {
    NONE,
    FAR,
    CORRECT,
    SAME,
}

var grade_diff_threshold = {
    Grade.NONE: 100.0,
    Grade.FAR: 50.0,
    Grade.CORRECT: 5.0,
    Grade.SAME: 1.0,
}


class ChannelGrade:
    var grade: Grade
    var difference: float


    func _init(_grade: Grade = Grade.NONE, _difference: float = 0.0) -> void:
        grade = _grade
        difference = _difference


    func _to_string() -> String:
        var grade_str = ""
        match grade:
            Grade.NONE:
                grade_str = "NONE"
            Grade.FAR:
                grade_str = "FAR"
            Grade.CORRECT:
                grade_str = "CORRECT"
            Grade.SAME:
                grade_str = "SAME"
        return "(grade=%s, difference=%.2f)" % [grade_str, difference]



class AnswerGrade:
    var channel_grades: Array[ChannelGrade] = []
    func _init():
        for i in range(4):
            channel_grades.append(ChannelGrade.new())


    func _to_string() -> String:
        var channels_str = ""
        for i in range(channel_grades.size()):
            channels_str += "\n    " + str(channel_grades[i])
            if i < channel_grades.size() - 1:
                channels_str += ","
        return "AnswerGrade([%s\n])" % channels_str



class PuzzleInfo:
    var time_started: float = 0.0
    var time_ended: float = 0.0
    var answers: Array[AnswerGrade] = []
    func _init():
        time_started = 0
        time_ended = 0
        for i in range(6):
            answers.append(AnswerGrade.new())
# endregion

# region BG Music
# ============================================================================
# BACKGROUND MUSIC
# ============================================================================
var music_player: AudioStreamPlayer


func _init_background_music() -> void:
    # Create and configure music player
    music_player = AudioStreamPlayer.new()
    music_player.name = "BackgroundMusic"
    add_child(music_player)

    var music_stream = load("res://assets/sounds/Yoga (Wii Fit).mp3") as AudioStream
    if music_stream:
        music_player.stream = music_stream
        music_player.volume_db = -10  # Adjust volume as needed
        music_player.autoplay = false
        print("Background music loaded successfully")
    else:
        push_error("Failed to load background music stream.")
# endregion


# region Init
# ============================================================================
# INITIALIZATION
# ============================================================================
func _ready() -> void:
    set_theme(theme)
    _init_background_music()
# endregion
