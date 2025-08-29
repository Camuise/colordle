extends OptionButton


func _ready() -> void:
    # loop over global ENUM
    clear()
    for format_name in Globals.ColordleFormat.keys():
        add_item(format_name)
