extends Node

# region Theme System
# ============================================================================
# THEME SYSTEM
# ============================================================================
enum ColorTheme {
    LIGHT,
    DARK
}
enum RainbowCycle {
    OFF,
    CYCLE
}
@export var theme: ColorTheme = ColorTheme.LIGHT
@export var rainbow_cycle: RainbowCycle = RainbowCycle.CYCLE
signal theme_changed(new_theme: ColorTheme)
signal rainbow_cycle_changed(new_mode: RainbowCycle)


func set_theme(new_theme: ColorTheme) -> void:
    if theme != new_theme:
        theme = new_theme
        emit_signal("theme_changed", theme)


func set_rainbow_cycle(new_mode: RainbowCycle) -> void:
    if rainbow_cycle != new_mode:
        rainbow_cycle = new_mode
        emit_signal("rainbow_cycle_changed", rainbow_cycle)
# endregion

# region Game State
# ============================================================================
# GAME STATE MANAGEMENT
# ============================================================================
enum GameState {
    MAIN_MENU,
    TUTORIAL,
    DAILY,
    MARATHON,
    RESULTS_DAILY,
    RESULTS_MARATHON,
    OPTIONS
}
@export var game_state: GameState = GameState.MAIN_MENU
signal game_state_changed(old_state: GameState, new_state: GameState)
signal show_results(puzzle_info: PuzzleInfo, game_mode: GameState, time_taken: float)


func set_game_state(new_state: GameState) -> void:
    if game_state == new_state:
        return

    var old_state = game_state
    game_state = new_state

    add_game_mode_scene(game_state)

    emit_signal("game_state_changed", old_state, game_state)

var daily_scene: Node = preload("res://daily.tscn").instantiate()
var marathon_scene: Node = preload("res://marathon.tscn").instantiate()
var results_daily_scene: Node = preload("res://results_daily.tscn").instantiate()
var results_marathon_scene: Node = preload("res://results_marathon.tscn").instantiate()
var options_scene: Node = preload("res://options.tscn").instantiate()
var tutorial_scene: Node = preload("res://tutorial.tscn").instantiate()



func add_game_mode_scene(new_mode: GameState) -> void:
    var main_node = get_tree().root.get_node("Main")
    var screen_size: Vector2 = get_viewport().get_visible_rect().size
    match new_mode:
        GameState.DAILY:
            main_node.add_child(daily_scene)
            daily_scene.owner = main_node
            daily_scene.position = Vector2(2, 0) * screen_size
        GameState.RESULTS_DAILY:
            # ensure instance has a unique name so we can find/remove it later
            results_daily_scene.name = "ResultsDaily"
            main_node.add_child(results_daily_scene)
            results_daily_scene.owner = main_node
            results_daily_scene.position = Vector2(2, 1) * screen_size
        GameState.RESULTS_MARATHON:
            results_marathon_scene.name = "ResultsMarathon"
            main_node.add_child(results_marathon_scene)
            results_marathon_scene.owner = main_node
            results_marathon_scene.position = Vector2(2, 1) * screen_size
        GameState.MARATHON:
            main_node.add_child(marathon_scene)
            marathon_scene.owner = main_node
            marathon_scene.position = Vector2(2, 2) * screen_size
        GameState.OPTIONS:
            main_node.add_child(options_scene)
            options_scene.owner = main_node
            options_scene.position = Vector2(0, 2) * screen_size
        GameState.TUTORIAL:
            main_node.add_child(tutorial_scene)
            tutorial_scene.owner = main_node
            tutorial_scene.position = Vector2(0, -2) * screen_size
        _:
            get_tree().create_timer(1.5).timeout.connect(remove_game_nodes)


func remove_game_nodes() -> void:
    var main_node = get_tree().root.get_node("Main")
    var current_daily_node = main_node.get_node_or_null("Daily")
    if current_daily_node:
        daily_scene = current_daily_node
        main_node.remove_child(current_daily_node)
    var current_marathon_node = main_node.get_node_or_null("Marathon")
    if current_marathon_node:
        marathon_scene = current_marathon_node
        main_node.remove_child(current_marathon_node)
    # Results nodes may be named several ways depending on version. Handle them all.
    var current_results_daily = main_node.get_node_or_null("ResultsDaily")
    if current_results_daily:
        results_daily_scene = current_results_daily
        main_node.remove_child(current_results_daily)

    var current_results_marathon = main_node.get_node_or_null("ResultsMarathon")
    if current_results_marathon:
        results_marathon_scene = current_results_marathon
        main_node.remove_child(current_results_marathon)

    var current_options_node = main_node.get_node_or_null("Options")
    if current_options_node:
        options_scene = current_options_node
        main_node.remove_child(current_options_node)

    # Backwards-compat: some older scenes may have root named "Results". Detect whether
    # it's the daily or marathon variant by checking its children, then reassign.
    var current_results_node = main_node.get_node_or_null("Results")
    if current_results_node:
        if current_results_node.get_node_or_null("Daily"):
            results_daily_scene = current_results_node
        elif current_results_node.get_node_or_null("Marathon"):
            results_marathon_scene = current_results_node
        main_node.remove_child(current_results_node)


func show_game_results(puzzle_info: PuzzleInfo, game_mode: GameState) -> void:
    assert(game_mode in [GameState.DAILY, GameState.MARATHON], "game_mode must be DAILY or MARATHON")
    # Route to the specific results scene depending on which game mode produced the results
    var results_state = GameState.RESULTS_DAILY if game_mode == GameState.DAILY else GameState.RESULTS_MARATHON
    set_game_state(results_state)
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

@export var todays_color: Color = get_todays_color()

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


func get_todays_color(time: bool = false) -> Color:
    # step 1: get today's date in UNIX
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
    rng.seed = hash(_today_unix)  # Hash the seed for better distribution

    # step 5: generate a random color with more varied hue and saturation
    var hue = rng.randf()
    var saturation = rng.randf_range(0.5, 1.0)  # Avoid dull colors
    var value = rng.randf_range(0.5, 1.0)  # Avoid too dark colors
    var generated_color = Color.from_hsv(hue, saturation, value)
    print_debug("Generated HSV color: %s" % generated_color)
    return generated_color


func get_puzzle_number() -> int:
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


func get_todays_date() -> String:
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

var grade_threshold = {
    Grade.NONE: 100.0,
    Grade.FAR: 50.0,
    Grade.CORRECT: 5.0,
    Grade.SAME: 1.0,
}

var grade_colors = {
    Grade.NONE: Color(0.2, 0.2, 0.2),  # Gray
    Grade.FAR: Color(1, 0.5, 0),  # Orange
    Grade.CORRECT: Color(0, 1, 0),  # Green
    Grade.SAME: Color(0.643, 0.369, 0.914),  # Purple
}


class ChannelGrade:
    var grade: Grade
    var value: float
    var difference: float


    func _init(_grade: Grade = Grade.NONE, _value: float = 0.0, _difference: float = 0.0) -> void:
        grade = _grade
        value = _value
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
        return "(grade=%s, value=%.2f, difference=%.2f)" % [grade_str, value, difference]


class AnswerAttempt:
    var color: Color = Color(0, 0, 0, 0)  # null color (transparent black)
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
        return "AnswerAttempt(color=%s, [%s\n])" % [color, channels_str]


class PuzzleInfo:
    var time_started: float = 0.0
    var time_ended: float = 0.0
    var answers: Array[AnswerAttempt] = []
    var successful: bool = false


    func _init():
        time_started = 0
        time_ended = 0
        for i in range(6):
            answers.append(AnswerAttempt.new())
# endregion

# region Infinidle Mode
# ============================================================================
# INFINIDLE-SPECIFIC THINGS
# ============================================================================
signal infinidle_complete(infinidle_stats: InfinidleStats)


class InfinidleStats:
    var total_wins: int = 0
    var perfect_wins: int = 0
    var win_rows: Dictionary = { }


    func _init():
        total_wins = 0
        perfect_wins = 0
        win_rows = {
            1: 0,
            2: 0,
            3: 0,
            4: 0,
            5: 0,
            6: 0,
        }


    func _to_string() -> String:
        return "InfinidleStats(\n    total_wins=%d,\n    perfect_wins=%d,\n    win_rows=%s)" % [total_wins, perfect_wins, str(win_rows)]


    func _reset_infinidle_stats() -> void:
        total_wins = 0
        perfect_wins = 0
        for key in win_rows.keys():
            win_rows[key] = 0


    func _record_infinidle_win(row: int) -> void:
        if win_rows.has(row):
            win_rows[row] += 1


func broadcast_infinidle_complete(infinidle_stats: InfinidleStats) -> void:
    emit_signal("infinidle_complete", infinidle_stats)
# endregion


# region Color Utilities
# ============================================================================
# COLOR CHANNEL UTILITIES
# ============================================================================
# Helper function to get channel colors for gameplay (returns array with answer and correct colors)
func get_channel_colors(channel: int, new_color: Color, correct_color: Color) -> Array:
    if channel == 3:
        return [new_color, correct_color]
    match colordle_format:
        ColorFormat.RGB:
            match channel:
                0:
                    return [Color(new_color.r, 0, 0), Color(correct_color.r, 0, 0)]
                1:
                    return [Color(0, new_color.g, 0), Color(0, correct_color.g, 0)]
                2:
                    return [Color(0, 0, new_color.b), Color(0, 0, correct_color.b)]
        ColorFormat.HSV:
            match channel:
                0:
                    return [Color.from_hsv(new_color.h, 1, 1), Color.from_hsv(correct_color.h, 1, 1)]
                1:
                    return [Color.from_hsv(new_color.h, new_color.s, 1), Color.from_hsv(correct_color.h, correct_color.s, 1)]
                2:
                    return [Color.from_hsv(0, 0, new_color.v), Color.from_hsv(0, 0, correct_color.v)]
    return [Color(), Color()]


# Helper function to get channel color for display (returns single color based on stored values)
func get_channel_color_for_display(channel: int, channel_values: Array) -> Color:
    # channel_values should contain [r, g, b] or [h, s, v] depending on current format
    if channel == 3:
        # For the full color channel, reconstruct the full color
        match colordle_format:
            ColorFormat.RGB:
                return Color(channel_values[0], channel_values[1], channel_values[2])
            ColorFormat.HSV:
                return Color.from_hsv(channel_values[0], channel_values[1], channel_values[2])

    # For individual channels, show the channel-specific color
    match colordle_format:
        ColorFormat.RGB:
            match channel:
                0:
                    return Color(channel_values[0], 0, 0)
                1:
                    return Color(0, channel_values[1], 0)
                2:
                    return Color(0, 0, channel_values[2])
        ColorFormat.HSV:
            match channel:
                0:
                    return Color.from_hsv(channel_values[0], 1, 1)
                1:
                    return Color.from_hsv(channel_values[0], channel_values[1], 1)
                2:
                    return Color.from_hsv(0, 0, channel_values[2])

    return Color(0.5, 0.5, 0.5)  # Default gray fallback


# Helper function to extract channel value from a color based on current format and channel index
func get_channel_value(color: Color, channel_index: int) -> float:
    match colordle_format:
        ColorFormat.RGB:
            match channel_index:
                0: return color.r
                1: return color.g
                2: return color.b
                _: return 1.0  # For channel 3 (full color), return default
        ColorFormat.HSV:
            match channel_index:
                0: return color.h
                1: return color.s
                2: return color.v
                _: return 1.0  # For channel 3 (full color), return default
    return 1.0  # Default fallback
# endregion

# region Global Audio
# ============================================================================
# BACKGROUND MUSIC AND SOUND VOLUME
# ============================================================================
var music_player: AudioStreamPlayer
@export var music_volume: float = 1.0
@export var sfx_volume: float = 1.0


func _init_background_music() -> void:
    # Create and configure music player
    music_player = AudioStreamPlayer.new()
    music_player.name = "BackgroundMusic"
    add_child(music_player)

    var music_stream = load("res://assets/sounds/Yoga (Wii Fit).mp3") as AudioStream
    if music_stream:
        music_player.stream = music_stream
        music_player.volume_db = linear_to_db(music_volume)
        music_player.autoplay = false
        print("Background music loaded successfully")
    else:
        push_error("Failed to load background music stream.")


func set_music_volume(new_volume: float) -> void:
    music_volume = clamp(new_volume, 0.0, 1.0)
    if music_player:
        music_player.volume_db = linear_to_db(music_volume)

func set_sfx_volume(new_volume: float) -> void:
    sfx_volume = clamp(new_volume, 0.0, 1.0)
# endregion


# region Utilities
# ============================================================================
# GENERAL UTILITIES
# ============================================================================
func round4(value: float) -> String:
    var rounded = str(abs(100 - (round(value * 100) / 100)))
    # if 3 non-zero chars before dot, drop all decimals
    if rounded.find(".") == 3:
        return rounded.split(".")[0] + "."
    # if 2 non-zero digits before the decimal, drop last decimal
    if rounded.find(".") == 2:
        return rounded.substr(0, 4)
    # only 1 non-zero digit before the decimal, drop padding to left
    return rounded.pad_decimals(2)


# region Init
# ============================================================================
# INITIALIZATION
# ============================================================================
func _ready() -> void:
    set_theme(theme)
    _init_background_music()
    remove_game_nodes()
# endregion
