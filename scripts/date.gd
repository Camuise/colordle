extends Label

var date_string: String


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    date_string = _get_date_string()
    self.text = date_string


func _get_date_string() -> String:
    # format as DayOfWeek, Month Day+Suffix
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
    return "%s, %s %s%s" % [day_of_week, month, day, suffix]


func recenter_label() -> void:
    # first, resize to match current label text
    self.size = self.get_minimum_size()
    # second, move label
    self.position.x = get_viewport().size.x / 2 - self.size.x / 2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    var now: String = _get_date_string()
    if now != date_string:
        date_string = now
        self.text = date_string
