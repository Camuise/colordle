extends "res://scripts/date.gd"


func _get_date_string() -> String:
    # format as DayOfWeek, Month Day+Suffix, HH:MM
    var now = Time.get_datetime_dict_from_system()
    var possible_days: Array[String] = [
        "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"
    ]
    var day_of_week = possible_days[now.weekday]
    var possible_months: Array[String] = [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ]
    var month = possible_months[now.month - 1]
    var day = str(now.day)
    var suffix = ""
    var last_digit = day[day.length() - 1]
    match last_digit:
        "1":
            suffix = "st"
        "2":
            suffix = "nd"
        "3":
            suffix = "rd"
        _:
            suffix = "th"
    var hour = str(now.hour).pad_zeros(2)
    var minute = str(now.minute).pad_zeros(2)
    return "%s, %s %s%s %s:%s" % [day_of_week, month, day, suffix, hour, minute]


func _get_todays_color() -> Color:
    # step 1: get today's date in UNIX
    var _today: Dictionary = Time.get_datetime_dict_from_system()

    # skips stripping hour min and sec

    # step 4: use that to seed a random number generator
    var rng = RandomNumberGenerator.new()
    rng.seed = _today

    # step 5: generate a random color
    var generated_color = Color.from_hsv(rng.randf(), rng.randf(), rng.randf())
    print_debug("Generated HSV color: %s" % generated_color)
    return generated_color


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    pass


func _new_colordle_day() -> void:
    date_string = _get_date_string()
    self.text = date_string
    recenter_label()
