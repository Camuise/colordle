extends VBoxContainer

# select all the sliders
@onready var sliders: Array[Slider] = []
@onready var labels: Array[Label] = []
@onready var backgrounds: Array[TextureRect] = []
@onready var result_color: ColorRect = %InputResultColor
signal answer_entered(new_answer: Color)


func _get_nodes():
    var base_path: GridContainer = $SliderContainer
    for i in range(3):
        sliders.append(base_path.get_node("Slider%d/Slider" % i))
        backgrounds.append(base_path.get_node("Slider%d/SliderBG" % i))
        labels.append(base_path.get_node("Label%d" % i))

    # print out all new nodes
    print_debug("Sliders: %s" % str(sliders))
    print_debug("Labels: %s" % str(labels))
    print_debug("Backgrounds: %s" % str(backgrounds))


func _get_rgb_gradient(slider_idx: int) -> Gradient:
    var gradient := Gradient.new()
    gradient.offsets = [0.0, 1.0]
    match slider_idx:
        0:
            labels[0].text = "Red"
            gradient.colors = PackedColorArray([
                Color(0.0, sliders[1].value, sliders[2].value),
                Color(1.0, sliders[1].value, sliders[2].value)
            ])
        1:
            labels[1].text = "Green"
            gradient.colors = PackedColorArray([
                Color(sliders[0].value, 0.0, sliders[2].value),
                Color(sliders[0].value, 1.0, sliders[2].value)
            ])
        2:
            labels[2].text = "Blue"
            gradient.colors = PackedColorArray([
                Color(sliders[0].value, sliders[1].value, 0.0),
                Color(sliders[0].value, sliders[1].value, 1.0)
            ])
    return gradient


func _get_hsv_gradient(slider_idx: int) -> Gradient:
    var gradient := Gradient.new()
    match slider_idx:
        0:
            labels[0].text = "Hue"
            var rainbow := []
            var offsets := []
            var hueSteps := 6
            for step in range(hueSteps + 1):
                var t := float(step) / hueSteps
                rainbow.append(Color.from_hsv(t, 1.0, 1.0))
                offsets.append(t)
            gradient.colors = PackedColorArray(rainbow)
            gradient.offsets = offsets
        1:
            labels[1].text = "Sat."
            gradient.offsets = [0.0, 1.0]
            gradient.colors = PackedColorArray([
                Color.from_hsv(sliders[0].value, 0.0, sliders[2].value),
                Color.from_hsv(sliders[0].value, 1.0, sliders[2].value)
            ])
        2:
            labels[2].text = "Value"
            gradient.offsets = [0.0, 1.0]
            gradient.colors = PackedColorArray([
                Color.from_hsv(sliders[0].value, sliders[1].value, 0.0),
                Color.from_hsv(sliders[0].value, sliders[1].value, 1.0)
            ])
    return gradient


func _update_sliders() -> void:
    for i in sliders.size():
        var gradient: Gradient
        match Globals.colordle_format:
            Globals.ColorFormat.RGB:
                gradient = _get_rgb_gradient(i)
            Globals.ColorFormat.HSV:
                gradient = _get_hsv_gradient(i)
        var texture := GradientTexture2D.new()
        texture.gradient = gradient
        # honestly, setting the size here doesn't really do anything
        # since the TextureRect will just stretch the gradient to fit
        texture.width = 315
        texture.height = 30
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


func _ready() -> void:
    _get_nodes()
    _update_sliders()
    _update_result_color()


func _process(_delta: float) -> void:
    _update_sliders()
    _update_result_color()


func _on_enter_button_pressed() -> void:
    var new_answer: Color
    match Globals.colordle_format:
        Globals.ColorFormat.RGB:
            new_answer = Color(sliders[0].value, sliders[1].value, sliders[2].value)
        Globals.ColorFormat.HSV:
            new_answer = Color.from_hsv(sliders[0].value, sliders[1].value, sliders[2].value)
    emit_signal("answer_entered", new_answer)
