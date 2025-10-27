extends PanelContainer

@onready var message_label: RichTextLabel = $Message


func set_message(text: String) -> void:
    message_label.text = text


func _ready() -> void:
    message_label.bbcode_enabled = true
    set_message("[b]If you see this message, something broke.[/b]\n Please report this to @issac on Slack!")
