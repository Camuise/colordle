extends VBoxContainer

# select all the sliders
@onready var sliders: Array[Slider] = []
@onready var labels: Array[Label] = []
@onready var backgrounds: Array[Sprite2D] = []
@onready var result_color: ColorRect = %InputResultColor

func _get_nodes():
    for child in get_children():
        if child is Slider:
            sliders.append(child)

        elif child is Label:
            labels.append(child)

        elif child is Sprite2D:
            backgrounds.append(child)

func _update_result_color() -> void:
    Globals.FormatToConstructor[Globals.colordle_format].call(sliders[0].value, sliders[1].value, sliders[2].value)

func _update_sliders() -> void:
    pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    _get_nodes()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
