extends Control

@onready var bar := $ProgressBar
@export var progress: float:
    set(value):
        bar.value = value
    get:
        return bar.value
