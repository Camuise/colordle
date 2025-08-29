extends OptionButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    # loop over global ENUM
    clear()
    for format_name in Globals.ColordleFormat.keys():
        add_item(format_name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
