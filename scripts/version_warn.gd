extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var version = ProjectSettings.get_setting("application/config/version", "unknown")
    var successfulLookup = version != "unknown"
    var isDevBuild = successfulLookup and version.find("-dev") != -1
    if isDevBuild:
        self.text = tr("You're running v%s, a development build!\nYou may see some bugs and missing features.") % version
    elif !successfulLookup:
        self.text = tr("You're running an unknown version of Colordle!\nPlease do not report bugs with this version.")
    else:
        self.visible = false
        self.text = ""
    Globals.connect("language_changed", Callable(self, "_on_language_changed"))

# update when language changes
func _on_language_changed(_new_language: String) -> void:
    _ready()