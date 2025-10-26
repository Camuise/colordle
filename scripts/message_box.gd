extends PanelContainer

@onready var message_label: RichTextLabel = $Message
@onready var sacrificial_label: RichTextLabel = get_parent().get_node("SacrificialMessage")
@onready var font_size: int = message_label.get_theme_font_size("normal_font_size")
@onready var line_separation: int = message_label.get_theme_constant("line_separation")
var max_width: int = 200  # maximum width of the message box

func set_message(text: String) -> void:
    # Set the message text and adjust the size of the message box accordingly
    sacrificial_label.text = text
    await _fit_width()
    size = message_label.size + Vector2(20, 20)  # add some padding


# yoinked from https://forum.godotengine.org/t/auto-resizing-richtextlabel-with-minimum-and-maximum-size/46051
func _fit_width() -> void:
    # block the signals so "finished" does not trigger this function again
    set_block_signals(true)
    var original_autowrap = sacrificial_label.autowrap_mode
    # disable autowrap
    sacrificial_label.autowrap_mode = TextServer.AUTOWRAP_OFF
    # make it 0, 0
    size = Vector2.ZERO
    # wait one frame
    await get_tree().process_frame
    # now we have the size with no autowrap
    # if the width is bigger than max width clamp it
    var w = clampf(sacrificial_label.size.x, 0, max_width)
    var h = sacrificial_label.size.y
    # restore the autowrap mode
    sacrificial_label.autowrap_mode = original_autowrap
    # set the maximum size we got
    sacrificial_label.size.x = w
    # wait one frame for the text to resize
    await get_tree().process_frame
    # if the height is bigger than before we have multiple lines
    # and we may need to make the width smaller
    if sacrificial_label.size.y > h:
        # save the height
        h = sacrificial_label.size.y
        # keep lowering the width until the height changes
        while true:
            # lower the width a bit
            sacrificial_label.size.x -= 10
            # wait one frame
            await get_tree().process_frame
            # check if the height changed
            if not is_equal_approx(sacrificial_label.size.y, h):
                # if it changed we made the textbox too small
                # restore the width and break the while loop
                sacrificial_label.size.x += 10
                break
    # wait one frame
    await get_tree().process_frame
    # restore the height
    sacrificial_label.size.y = h

    # copy stuff to the real label
    print("Final size: " + str(sacrificial_label.size))
    message_label.text = sacrificial_label.text
    message_label.autowrap_mode = sacrificial_label.autowrap_mode
    message_label.custom_minimum_size = sacrificial_label.size

    # unblock the signals
    set_block_signals(false)

func _ready() -> void:
    message_label.bbcode_enabled = true
    sacrificial_label.size = Vector2.ZERO
    sacrificial_label.fit_content = true
    sacrificial_label.finished.connect(_fit_width, CONNECT_DEFERRED)
    set_message("This is a message box.\nYou can use [b]BBCode[/b] formatting here. \n and and and and and and and and and and and and and and and and and and and and and and and and and and and and and and and and and and and and and and and and and and and and and and and and and and and and and and and and ")
