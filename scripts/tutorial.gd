extends Control


enum Stages {
    WELCOME,
    HOW_TO_PLAY,
    COLOR_MEANING,
    GOOD_LUCK
}

enum StepType {
    MESSAGE,
    RUN_FUNCTION
}

var lines := [
    {
        "step": StepType.MESSAGE,
        "text": "Hello, and welcome to [b]Colordle[/b]! I'm Wheely, and I'll guide you through the game.",
    },
    {
        "step": StepType.MESSAGE,
        "text": "Let's go over how to play Colordle!",
    },
    {
        "step": StepType.RUN_FUNCTION,
        "function_name": "_toggle_daily",
    },
    {
        "step": StepType.MESSAGE,
        "text": "Color Meaning:\n[b]Green[/b]: Correct color in the correct position.\n[b]Yellow[/b]: Correct color but in the wrong position.\n[b]Gray[/b]: Color not in the combination.",
    },
    {
        "step": StepType.MESSAGE,
        "text": "Good Luck!\nReady to test your color skills? Click anywhere to start playing Colordle!",
    },
]


@onready var message_label: RichTextLabel = $Instruction/MessageBox/Message
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    Globals.connect("game_state_changed", Callable(self, "_on_game_state_changed"))

func _on_game_state_changed(_old_state: Globals.GameState, new_state: Globals.GameState) -> void:
    if new_state == Globals.GameState.TUTORIAL:
        for line in lines:
            match line.step:
                StepType.MESSAGE:
                    _show_message(line.text)
                    await _wait_for_click()
                StepType.RUN_FUNCTION:
                    call(line.function_name)
                _:
                    pass

func _wait_for_click() -> void:
    _clicked = false
    while not _clicked:
        await get_tree().process_frame

# process input for ui enter
var _clicked: bool = false
func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_select"):
        _clicked = true

func _show_message(text: String) -> void:
    message_label.bbcode_enabled = true
    message_label.text = text

func _toggle_daily() -> void:
    var tutorial_interface: Control = $TutorialInterface
    tutorial_interface.visible = not tutorial_interface.visible