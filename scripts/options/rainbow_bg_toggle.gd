extends CheckButton

signal on_rainbow_cycle_changed(new_mode)


func _pressed() -> void:
    if Globals.rainbow_cycle == Globals.RainbowCycle.OFF:
        Globals.set_rainbow_cycle(Globals.RainbowCycle.CYCLE)
    else:
        Globals.set_rainbow_cycle(Globals.RainbowCycle.OFF)
    emit_signal("on_rainbow_cycle_changed", Globals.rainbow_cycle)
