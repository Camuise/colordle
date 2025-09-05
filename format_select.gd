extends OptionButton


func _ready() -> void:
    # loop over global ENUM
    clear()
    for format_name in Globals.ColorFormat.keys():
        add_item(format_name)


func item_selected(index: int) -> void:
    Globals.set_color_format(Globals.ColorFormat.values()[index])
    print_debug("Color format changed to: %s" % Globals.ColorFormat.values()[index])
