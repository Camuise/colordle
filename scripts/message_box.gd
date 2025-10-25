extends PanelContainer

@onready var message_label: RichTextLabel = $Message
@onready var font_size: int = message_label.get_theme_font_size("normal_font_size")
@onready var line_separation: int = message_label.get_theme_constant("line_separation")
var max_width: int = 400  # maximum width of the message box

func set_message(text: String) -> void:
    # Set the message text and adjust the size of the message box accordingly
    message_label.text = text
    message_label.size = Vector2.ZERO
    message_label.fit_content = true
    message_label.finished.connect(_fit_width, CONNECT_DEFERRED)
    await _fit_width()
    size = message_label.size + Vector2(20, 20)  # add some padding


# yoinked from https://forum.godotengine.org/t/auto-resizing-richtextlabel-with-minimum-and-maximum-size/46051
func _fit_width() -> void:
    set_block_signals(true)
    var original_autowrap = message_label.autowrap_mode
    var tmp = message_label.global_position
    message_label.global_position.y = 100000
    message_label.autowrap_mode = TextServer.AUTOWRAP_OFF
    size = Vector2.ZERO
    await get_tree().process_frame
    var w = clampf(message_label.size.x, 0, max_width)
    var h = message_label.size.y
    message_label.autowrap_mode = original_autowrap
    message_label.size.x = w
    # wait one frame for the text to resize
    await get_tree().process_frame
    # if the height is bigger than before we have multiple lines
    # and we may need to make the width smaller
    if message_label.size.y > h:
        h = message_label.size.y
        # keep lowering the width until the height changes
        while true:
            message_label.size.x -= 10
            await get_tree().process_frame
            # check if the height changed
            if not is_equal_approx(message_label.size.y, h):
                # if it changed we made the textbox too small
                # restore the width and break the while loop
                message_label.size.x += 10
                break
    # wait one frame
    await get_tree().process_frame
    message_label.size.y = h
    message_label.global_position = tmp
    set_block_signals(false)

func _ready() -> void:
    message_label.bbcode_enabled = true
    set_message("This is a message box.\nYou can use [b]BBCode[/b] formatting here.")