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
        "text": "Now let's go over how to play the daily Colordle!",
    },
    {
        "step": StepType.RUN_FUNCTION,
        "function_name": "_toggle_daily",
    },
    {
        "step": StepType.MESSAGE,
        "text": "In Colordle, your goal is to guess the hidden color by adjusting three sliders in whatever color space you want, which changes how the color is represented. Currently, you can choose between RGB and HSV.",
    },
    {
        "step": StepType.MESSAGE,
        "text": "You can switch between color spaces using the drop-down menu above the sliders. Try it out! Just press continue to proceed when you're ready.",
    },
    {
        "step": StepType.MESSAGE,
        "text": "After selecting your color space, adjust the sliders to make your guess for the hidden color. Each slider represents a different component of the color space you've chosen, as shown by the labels next to the sliders.",
    },
    {
        "step": StepType.MESSAGE,
        "text": "The color whose values you're adjusting is shown in the preview box below the sliders, so you can see how your adjustments change the color.",
    },
    {
        "step": StepType.MESSAGE,
        "text": "You may also have noticed the slider colors change as you adjust them. This is to help you visualize the color you're creating based on your slider values.",
    },
    {
        "step": StepType.MESSAGE,
        "text": "Once you've made your guess, you can submit it with the ↵ button. After submitting, you'll receive feedback on how close your guess was to the hidden color.",
    },
    {
        "step": StepType.MESSAGE,
        "text": "You have a total of 6 attempts to guess the correct color. After each guess, the sliders will stay as they , and you can adjust them again for your next attempt.",
    },
    {
        "step": StepType.MESSAGE,
        "text": "Outline Meanings:\n[color=gray][b]Gray[/b][/color]: Your guess for that slider is completely wrong.\n[color=Orange][b]Orange[/b][/color]: Your guess for that slider is far off, but approaching.\n[color=green][b]Green[/b][/color]: Your guess is correct, within 5% of the answer.\n[color=purple][b]Purple[/b][/color]: Your guess is perfect! It was within 1% of the answer.",
    },
    {
        "step": StepType.MESSAGE,
        "text": "Good Luck!\nReady to test your color skills? Click anywhere to start playing Colordle!",
    },
]


@onready var message_label: RichTextLabel = $Instruction/MessageBox/Message
@onready var tutorial_interface: Control = $TutorialInterface
@onready var input_blocker: ColorRect = $InputBlocker
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    Globals.connect("game_state_changed", Callable(self, "_on_game_state_changed"))


func _on_game_state_changed(_old_state: Globals.GameState, new_state: Globals.GameState) -> void:
    if new_state != Globals.GameState.TUTORIAL:
        return

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
    tutorial_interface.visible = not tutorial_interface.visible
    input_blocker.visible = tutorial_interface.visible
