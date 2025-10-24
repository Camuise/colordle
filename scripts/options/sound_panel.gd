extends GridContainer

@onready var music_slider: HSlider = $MusicHSlider
@onready var sfx_slider: HSlider = $SFXHSlider


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    music_slider.value = Globals.music_volume
    sfx_slider.value = Globals.sfx_volume

    music_slider.connect("value_changed", Callable(self, "_on_music_volume_changed"))
    sfx_slider.connect("value_changed", Callable(self, "_on_sfx_volume_changed"))


func _on_music_volume_changed(value: float) -> void:
    Globals.set_music_volume(value)


func _on_sfx_volume_changed(value: float) -> void:
    Globals.set_sfx_volume(value)
