extends OptionButton


func _ready() -> void:
    # loop over global ENUM
    clear()
    for format_name in Globals.ColordleFormat.keys():
        add_item(format_name)


func item_selected(index: int) -> void:
    Globals.set_color_format(Globals.ColordleFormat.values()[index])
    print_debug("Color format changed to: %s" % Globals.ColordleFormat.values()[index])
