extends ColorRect


func _process(_delta: float) -> void:
    _resize_to_parent()


func _resize_to_parent() -> void:
    var parent_size: Vector2 = get_parent().size
    if (parent_size.x - 12) != size.x:
        size.x = parent_size.x - 12
