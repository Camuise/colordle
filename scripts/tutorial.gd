extends Control

enum Stages {
    WELCOME,
    HOW_TO_PLAY,
    COLOR_MEANING,
    GOOD_LUCK
}

enum StepType {
    MESSAGE,
    FUNCTION
}

var lines := [
    {
        "step": StepType.MESSAGE,
        "text": tr("Hello, and welcome to [b]Colordle[/b]! I'm Wheely, and I'll guide you through the game."),
    },
    {
        "step": StepType.MESSAGE,
        "text": tr("Now let's go over how to play the daily Colordle!"),
    },
    {
        "step": StepType.FUNCTION,
        "function_name": "_toggle_daily",
    },
    {
        "step": StepType.MESSAGE,
        "text": tr("In Colordle, your goal is to guess the color by adjusting three sliders in whatever color space you want, which changes how the color is represented. Currently, you can choose between RGB and HSV."),
    },
    {
        "step": StepType.MESSAGE,
        "text": tr("You can switch between color spaces using the drop-down menu above the sliders. Try it out! Just press continue to proceed when you're ready."),
    },
    {
        "step": StepType.MESSAGE,
        "text": tr("After selecting your color space, adjust the sliders to make your guess for the hidden color. Each slider represents a different component of the color space you've chosen, as shown by the labels next to the sliders."),
    },
    {
        "step": StepType.MESSAGE,
        "text": tr("The color whose values you're adjusting is shown in the preview box below the sliders, so you can see how your adjustments change the color."),
    },
    {
        "step": StepType.MESSAGE,
        "text": tr("You may also have noticed the slider colors change as you adjust them. This is to help you visualize the color you're creating based on your slider values."),
    },
    {
        "step": StepType.MESSAGE,
        "text": tr("Try guessing the color now by adjusting the sliders to your desired values! Press continue when you're ready to move on."),
    },
    {
        "step": StepType.MESSAGE,
        "text": tr("After submitting, you'll receive feedback on how close your guess was to the hidden color."),
    },
    {
        "step": StepType.MESSAGE,
        "text": tr("You have a total of 6 attempts to guess the correct color. After each guess, the sliders will stay as they are, and you can adjust them again for your next attempt."),
    },
    {
        "step": StepType.FUNCTION,
        "function_name": "_toggle_daily",
    },
    {
        "step": StepType.MESSAGE,
        "text": tr("Now, let's go over what the different outline colors mean for each slider after you make a guess. This is a lot of information, so pay close attention!"),
    },
    {
        "step": StepType.MESSAGE,
        "text": tr("The outline colors around each slider indicate how close your guess for that specific slider is to the correct value. There are four possible colors: Gray, Orange, Green, and Purple."),
    },
    {
        "step": StepType.MESSAGE,
        "text": tr("Here's what the colors mean:\n[color=gray][b]Gray[/b][/color]: Your guess for that slider is completely wrong.\n[color=Orange][b]Orange[/b][/color]: Your guess for that slider is far off, but approaching.\n[color=green][b]Green[/b][/color]: Your guess is correct, within 5% of the answer.\n[color=purple][b]Purple[/b][/color]: Your guess is perfect! It was within 1% of the answer."),
    },
    {
        "step": StepType.MESSAGE,
        "text": tr("The outline colors will update for each guess, so you can use them to gauge how close you are to the correct values."),
    },
    {
        "step": StepType.MESSAGE,
        "text": tr("It'll also show you how close you are to the correct color as a whole, using a percentage next to (during guessing) or on (during the results page) the preview box."),
    },
    {
        "step": StepType.MESSAGE,
        "text": tr("Now that you know how to play, you can turn off the tutorial button in options. Enjoy the game, and may the colors be ever in your favor!"),
    },
    {
        "step": StepType.FUNCTION,
        "function_name": "_go_to_main_menu",
    },
]


@onready var message_label: RichTextLabel = $Instruction/MessageBox/Message
@onready var tutorial_interface: Control = $TutorialInterface
@onready var input_blocker: ColorRect = $InputBlocker
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    Globals.connect("game_state_changed", Callable(self, "_on_game_state_changed"))
    tutorial_interface.visible = false
    input_blocker.visible = true


func _on_game_state_changed(_old_state: Globals.GameState, new_state: Globals.GameState) -> void:
    if new_state != Globals.GameState.TUTORIAL:
        return

    for line in lines:
        match line.step:
            StepType.MESSAGE:
                _show_message(line.text)
                await _wait_to_continue()
            StepType.FUNCTION:
                call(line.function_name)
            _:
                pass


func _wait_to_continue() -> void:
    _continuing = false
    while not _continuing:
        if is_inside_tree():
            await get_tree().process_frame
        else:
            break


# process input for ui enter
var _continuing: bool = false
func _input(event: InputEvent) -> void:
    if event.is_action_pressed("next_dialogue"):
        _continuing = true


func _show_message(text: String) -> void:
    message_label.bbcode_enabled = true
    message_label.text = text


func _toggle_daily() -> void:
    tutorial_interface.visible = not tutorial_interface.visible
    input_blocker.visible = not tutorial_interface.visible


func _go_to_main_menu() -> void:
    Globals.set_game_state(Globals.GameState.MAIN_MENU)
