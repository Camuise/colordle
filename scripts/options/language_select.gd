extends OptionButton

var languages: Array[Dictionary] = [
    { "name": tr("AutoLang"), "translation": "", "code": "auto" },
    { "name": "English", "translation": "(%s)" % tr("EnglishLang"), "code": "en" },
    { "name": "日本語", "translation": "(%s)" % tr("JapaneseLang"), "code": "ja" },
]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    # Populate the OptionButton with language names in the desired format
    for lang in languages:
        var display_text = "%s %s" % [lang["name"], lang["translation"]]
        add_item(display_text)
    get_popup().transparent_bg = true
    get_popup().transparent = true
    Globals.set_language("auto")


func _on_item_selected(index: int) -> void:
    var selected_code
    if index >= 0 and index < languages.size():
        selected_code = languages[index]["code"]
    else:
        selected_code = "auto"
    Globals.set_language(selected_code)
