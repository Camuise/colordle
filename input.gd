extends VBoxContainer

# select all the sliders
@onready var sliders: Array[Slider] = []
@onready var labels: Array[Label] = []
@onready var backgrounds: Array[Sprite2D] = []
@onready var result_color: ColorRect = %InputResultColor


func _get_nodes():
    var base_path: GridContainer = $SliderContainer
    for i in range(3):
        sliders.append(base_path.get_node("Slider%d/Slider" % i))
        backgrounds.append(base_path.get_node("Slider%d/Border/Sprite2D" % i))
        labels.append(base_path.get_node("Label%d" % i))

    # print out all new nodes
    print_debug("Sliders: %s" % str(sliders))
    print_debug("Labels: %s" % str(labels))
    print_debug("Backgrounds: %s" % str(backgrounds))


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
