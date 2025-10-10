extends Button

signal share_requested()


func _pressed() -> void:
    emit_signal("share_requested")
