# Colordle Localization Needs

Scripts with strings needing localization:

- [ ] `scripts/date_marathon.gd`: Month/ Day of the week names, Date formats
- [ ] `scripts/date.gd`: Month/ Day of the week names, Date formats
- [ ] `scripts/globals.gd`: `get_todays_date()`
- [ ] `scripts/message_box.gd`: error message
- [ ] `scripts/results_daily.gd`: title text, share text
- [ ] `scripts/results_marathon.gd`: title text, share text
- [ ] `scripts/tutorial.gd`: tutorial text
- [ ] `scripts/version_warn.gd`: version warning text

Scenes with hardcoded strings needing localization:

- [ ] `scenes/daily.tscn`: UI text
  - [ ] `Gameplay/AnswerDisplay/HeaderLabel` - "Your Answers"
  - [ ] `Header/Right/Date` - "Aug 24 2025"
  - [ ] `Gameplay/AnswerDisplay/NoAnswerContainer/EnterAGuess` - "Enter a guess for today's colordle!"
  - [ ] `Gameplay/Input/HeaderContainer/Label` - "Input"
  - [ ] `Gameplay/Input/HeaderContainer/FormatSelect` - Popup items: "RGB", "HSV"
  - [ ] `Gameplay/Input/SliderContainer/Label0` - "Slider0"
  - [ ] `Gameplay/Input/SliderContainer/Label1` - "Slider1"
  - [ ] `Gameplay/Input/SliderContainer/Label2` - "Slider2"
- [ ] `scenes/marathon.tscn`: UI text
  - [ ] `Header/Right/Infinidle` - "Infinidle"
  - [ ] `Header/Right/Ratio` - "1/1"
  - [ ] `Gameplay/AnswerDisplay/HeaderLabel` - "Your Answers"
  - [ ] `Gameplay/AnswerDisplay/NoAnswerContainer/EnterAGuess` - "Enter a guess for this colordle!"
- [ ] `scenes/options.tscn`: UI text
  - [ ] `Header/BackButton` - "Back"
  - [ ] `Header/Title` - "Options"
  - [ ] `TabContainer/Visual/VBoxContainer/Theme/ThemeLabel` - "Color Theme"
  - [ ] `TabContainer/Visual/VBoxContainer/BGColor/BGColorLabel` - "Rainbow Background"
  - [ ] `TabContainer/Audio/GridContainer/MusicLabel` - "Music"
  - [ ] `TabContainer/Audio/GridContainer/SFXLabel` - "SFX"
  - [ ] `TabContainer/About/CenterContainer/VBoxContainer/Label` - "Thank you for play Colordle!\n\nCredits:"
  - [ ] `TabContainer/About/CenterContainer/VBoxContainer/VBoxContainer/Label` - "Josh Wardle for creating Wordle, the inspiration for this game"
  - [ ] `TabContainer/About/CenterContainer/VBoxContainer/VBoxContainer/Label2` - "Lucide.dev for their amazing icons, which I based mines off of"
  - [ ] `TabContainer/About/CenterContainer/VBoxContainer/VBoxContainer/Label3` - "Thomas Stubblefield for running the Hack Club Shiba event"
- [ ] `scenes/results_daily.tscn`: UI text
  - [ ] `Daily/ShareButton` - "Share"
  - [ ] `Daily/ResultsDisplay/Title` - "Colordle 1023, 10/6"
  - [ ] `BackButton` - "Main Menu"
  - [ ] `Reaction` - "Good Job!"
  - [ ] `DetailedReaction` - "You just went straight for the answer, didn't ya?"
- [ ] `scenes/results_marathon.tscn`: UI text
  - [ ] `Marathon/ResultsDisplay/Header/Title` - "Colordle ∞, 10/6"
  - [ ] `Marathon/ResultsDisplay/Header/StreakCount` - "Streak: 203"
  - [ ] `Marathon/ResultsDisplay/BarGraph/Item0/Label0/Label` - "1"
  - [ ] `Marathon/ResultsDisplay/BarGraph/Item1/Label0/Label` - "2"
  - [ ] `Marathon/ResultsDisplay/BarGraph/Item2/Label0/Label` - "3"
  - [ ] `Marathon/ResultsDisplay/BarGraph/Item3/Label0/Label` - "4"
  - [ ] `Marathon/ResultsDisplay/BarGraph/Item4/Label0/Label` - "5"
  - [ ] `Marathon/ResultsDisplay/BarGraph/Item5/Label0/Label` - "6"
  - [ ] `Marathon/ShareButton` - "Share"
  - [ ] `BackButton` - "Main Menu"
  - [ ] `Reaction` - "Good Job!"
  - [ ] `DetailedReaction` - "You just went straight for the answer, didn't ya?"
- [ ] `scenes/title.tscn`: UI text
  - [ ] `Title/Welcome` - "Welcome to"
  - [ ] `Title/Colordle` - "Colordle"
  - [ ] `MenuContainer/TutorialButton` - "Tutorial"
  - [ ] `MenuContainer/DailyButton` - "Daily"
  - [ ] `MenuContainer/MarathonButton` - "Marathon"
  - [ ] `MenuContainer/OptionsButton` - "Options"
  - [ ] `Copyright` - "© Matcha Software, 2025\nMade for Hack Club Shiba, with <3"
- [ ] `scenes/tutorial.tscn`: UI text
  - [ ] `Instruction/MessageBox/Message` - "jijjoioioi hello and welcomet qweref\ndjoihdfslkhfsdlkfsdij second line"
  - [ ] `Instruction/ProceedLabel` - "[⇥] or right click to continue"
