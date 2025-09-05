extends OptionButton


func _ready() -> void:
    # loop over global ENUM
    clear()
    for format_name in Globals.ColorFormat.keys():
        add_item(format_name)

    select(Globals.colordle_format)

func _on_item_selected(index: int) -> void:
    Globals.set_color_format(Globals.ColorFormat.values()[index])
    print_debug("Color format changed to: %s" % Globals.ColorFormat.values()[index])
