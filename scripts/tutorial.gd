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
        "text": "Outline Meanings:\n[b]Gray[/b]: Your guess for that slider is completely wrong.\n[b]Yellow[/b]: Your guess for that slider is far off, but approaching.\n[b]Green[/b]: Your guess is correct, within 5% of the answer.\n[b]Purple[/b]: Your guess is perfect! It was within 1% of the answer.",
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
                    await _wait_to_continue()
                StepType.RUN_FUNCTION:
                    call(line.function_name)
                _:
                    pass

func _wait_to_continue() -> void:
    _continuing = false
    while not _continuing:
        await get_tree().process_frame

# process input for ui enter
var _continuing: bool = false
func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_select"):
        _continuing = true

func _show_message(text: String) -> void:
    message_label.bbcode_enabled = true
    message_label.text = text

func _toggle_daily() -> void:
    var tutorial_interface: Control = $TutorialInterface
    tutorial_interface.visible = not tutorial_interface.visible