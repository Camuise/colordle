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


func _update_sliders() -> void:
    for i in range(sliders.size()):
        var gradient = Gradient.new()
        match Globals.colordle_format:
            Globals.ColorFormat.RGB:
                gradient.offsets = [0.0, 1.0]
                if i == 0:
                    gradient.colors = PackedColorArray([
                        Color(0.0, sliders[1].value, sliders[2].value),
                        Color(1.0, sliders[1].value, sliders[2].value)
                    ])
                elif i == 1:
                    gradient.colors = PackedColorArray([
                        Color(sliders[0].value, 0.0, sliders[2].value),
                        Color(sliders[0].value, 1.0, sliders[2].value)
                    ])
                elif i == 2:
                    gradient.colors = PackedColorArray([
                        Color(sliders[0].value, sliders[1].value, 0.0),
                        Color(sliders[0].value, sliders[1].value, 1.0)
                    ])
            Globals.ColorFormat.HSV:
                gradient.offsets = [0.0, 1.0]
                if i == 0:
                    var rainbow: Array[Color] = []
                    var offsets: Array[float] = []
                    var steps = 6
                    for j in range(steps + 1):
                        var h = float(j) / steps
                        rainbow.append(Color.from_hsv(h, 1.0, 1.0))
                        offsets.append(h)
                    gradient.colors = PackedColorArray(rainbow)
                    gradient.offsets = offsets
                elif i == 1:
                    gradient.colors = PackedColorArray([
                        Color.from_hsv(sliders[0].value, 0.0, sliders[2].value),
                        Color.from_hsv(sliders[0].value, 1.0, sliders[2].value)
                    ])
                elif i == 2:
                    gradient.colors = PackedColorArray([
                        Color.from_hsv(sliders[0].value, sliders[1].value, 0.0),
                        Color.from_hsv(sliders[0].value, sliders[1].value, 1.0)
                    ])
        var texture = GradientTexture2D.new()
        texture.gradient = gradient
        texture.width = 315
        texture.height = 28
        backgrounds[i].texture = texture


func _update_result_color() -> void:
    var color: Color = Color(0, 0, 0)
    match Globals.colordle_format:
        Globals.ColorFormat.RGB:
            color = Color(sliders[0].value, sliders[1].value, sliders[2].value)
        Globals.ColorFormat.HSV:
            color = Color.from_hsv(sliders[0].value, sliders[1].value, sliders[2].value)

    # Update the result color display
    result_color.color = color


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    _get_nodes()
    _update_sliders()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
