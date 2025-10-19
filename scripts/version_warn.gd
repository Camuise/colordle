extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var version = ProjectSettings.get_setting("application/config/version", "unknown")
    var successfulLookup = version != "unknown"
    var isDevBuild = successfulLookup and version.find("-dev") != -1
    if isDevBuild:
        self.text = "You're running v%s, a development build!\nYou may see some bugs and missing features." % version
    elif !successfulLookup:
        self.text = "You're running an unknown version of Colordle!\nPlease do not report bugs with this version."
    else:
        self.visible = false
        self.text = ""
