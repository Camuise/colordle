extends ColorRect

# customizable sliders for color S and V
# to adjust saturation and value of the background color
@export_range(0.0, 1.0, 0.01) var saturation: float = 1.0
@export_range(0.0, 1.0, 0.01) var value: float = 1.0
@export_range(0.0, 1.0, 0.01) var alpha: float = 1.0

func _ready() -> void:
    # Get the global singleton
    # Set initial value based on theme
    _update_value_from_theme(Globals.theme)
    # Connect to theme change if signal exists
    if Globals.has_signal("theme_changed"):
        Globals.connect("theme_changed", Callable(self, "_on_theme_changed"))
    # Set the background color to a semi-transparent black
    self.color = Color.from_hsv(0.0, saturation, value, alpha)

    # play background music
    if Globals.background_music and not Globals.background_music.playing:
        Globals.background_music.play()

# Helper to update value based on theme
func _update_value_from_theme(theme_name: Globals.ColorTheme) -> void:
    match theme_name:
        Globals.ColorTheme.DARK:
            saturation = 0.8
            value = 0.2
        _:
            saturation = 0.5
            value = 1.0

# Called when theme changes
func _on_theme_changed(new_theme: Globals.ColorTheme) -> void:
    _update_value_from_theme(new_theme)

# Animate background color through ROYGBIV (rainbow) colors
func _process(_delta: float) -> void:
    var time = Time.get_ticks_msec() / 1000.0
    var hue = fmod(time * 0.02, 1.0) # Slow cycle through hues
    var rainbow_color = Color.from_hsv(hue, saturation, value, alpha)
    self.color = rainbow_color
