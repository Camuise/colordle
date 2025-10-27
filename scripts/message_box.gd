extends PanelContainer

@onready var message_label: RichTextLabel = $Message
@onready var font_size: int = message_label.get_theme_font_size("normal_font_size")
@onready var line_separation: int = message_label.get_theme_constant("line_separation")
var max_width: int = 200  # maximum width of the message box

func set_message(text: String) -> void:
    # Set the message text and adjust the size of the message box accordingly
    message_label.text = text

func _ready() -> void:
    message_label.bbcode_enabled = true
    set_message("[b]If you see this message, something broke.[/b]\n Please report this to @issac on Slack!")
