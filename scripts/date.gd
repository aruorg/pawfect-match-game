extends Control
## Date screen (cafe): a short quiz about the two cats.
## Right answers raise a cat's mood, wrong answers and timeouts lower it.

# --- Numbers that decide how the date plays. Change these to tune the game. ---

## Seconds the player has for each question.
const ROUND_SECONDS := 30.0
## Seconds the "right / wrong" message stays before the next question.
const FEEDBACK_SECONDS := 1.5

## Starting mood = START_MOOD + MOOD_PER_HEART for every compatibility heart.
const START_MOOD := 20
const MOOD_PER_HEART := 10
## How much a cat's mood changes after a question about that cat.
const MOOD_RIGHT := 20
const MOOD_WRONG := -15

## Button colours after answering: the right answer and a wrong pick.
const RIGHT_COLOR := Color(0.25, 0.65, 0.38)
const WRONG_COLOR := Color(0.85, 0.28, 0.28)
## Lighter versions for the "+20" / "-15" text on the dark background.
const MOOD_UP_COLOR := Color(0.5, 0.95, 0.62)
const MOOD_DOWN_COLOR := Color(1.0, 0.5, 0.5)

const SCORE_RIGHT := 100
const SCORE_PER_SECOND_LEFT := 10

# --- What is happening right now ---

var cat_a: Dictionary = {}
var cat_b: Dictionary = {}
var mood_a: int = 0
var mood_b: int = 0
var score: int = 0

var questions: Array = []
var round_index: int = 0       # 0 = first round
var time_left: float = 0.0
var waiting_for_answer: bool = false

# --- Nodes from the scene ---

@onready var score_label: Label = $TopPanel/ScoreLabel
@onready var round_label: Label = $TopPanel/RoundLabel
@onready var picture_a: TextureRect = $CatAPicture
@onready var picture_b: TextureRect = $CatBPicture
@onready var mood_label_a: Label = $MoodLabelA
@onready var mood_label_b: Label = $MoodLabelB
@onready var mood_bar_a: ProgressBar = $MoodBarA
@onready var mood_bar_b: ProgressBar = $MoodBarB
@onready var question_label: Label = $QuestionPanel/QuestionLabel
@onready var time_label: Label = $QuestionPanel/TimeLabel
@onready var timer_bar: ProgressBar = $QuestionPanel/TimerBar
@onready var option_buttons: Array = [
	$QuestionPanel/Options/Option1,
	$QuestionPanel/Options/Option2,
	$QuestionPanel/Options/Option3,
]
@onready var help_bubble_a: Panel = $HelpBubbleA
@onready var help_bubble_b: Panel = $HelpBubbleB
@onready var mood_change_a: Label = $MoodChangeA
@onready var mood_change_b: Label = $MoodChangeB
@onready var profile_popup: Control = $ProfilePopup
@onready var profile_card = $ProfilePopup/ProfileCard


func _ready() -> void:
	# If this screen is run on its own for testing (F6), use the first two cats.
	if GameState.cat_a.is_empty() or GameState.cat_b.is_empty():
		GameState.cat_a = CatData.CATS[0]
		GameState.cat_b = CatData.CATS[1]
	cat_a = GameState.cat_a
	cat_b = GameState.cat_b

	picture_a.texture = load(cat_a["image"])
	picture_b.texture = load(cat_b["image"])

	# Mirror a picture when the cat would look away from the table.
	# The left cat should look right, the right cat should look left.
	picture_a.flip_h = cat_a["faces"] == "left"
	picture_b.flip_h = cat_b["faces"] == "right"

	# Better matched cats start the date in a better mood.
	var hearts: int = Compatibility.check(cat_a, cat_b)["hearts"]
	mood_a = START_MOOD + MOOD_PER_HEART * hearts
	mood_b = mood_a

	questions = DateQuestions.make_questions(cat_a, cat_b)

	# Tell each answer button to call _on_option_pressed with its own number.
	for i in option_buttons.size():
		option_buttons[i].pressed.connect(_on_option_pressed.bind(i))

	timer_bar.max_value = ROUND_SECONDS
	_update_display()
	_start_round()


## Godot calls _process many times per second. "delta" is the time since the
## last call, so subtracting it makes time_left count down in real seconds.
func _process(delta: float) -> void:
	if not waiting_for_answer:
		return
	time_left -= delta
	timer_bar.value = time_left
	time_label.text = "%d s" % ceili(time_left)
	if time_left <= 0.0:
		_finish_round("")  # empty answer = the player ran out of time


func _start_round() -> void:
	var question: Dictionary = questions[round_index]
	round_label.text = "Date 1: Cafe  -  Round %d of %d" % [round_index + 1, questions.size()]
	question_label.text = question["text"]
	for i in option_buttons.size():
		option_buttons[i].text = question["options"][i]
		option_buttons[i].disabled = false
		_clear_button_color(option_buttons[i])

	# The "?" goes next to the cat who forgot. That is the OTHER cat than the
	# one the question is about: a question about cat B means cat A forgot.
	help_bubble_a.visible = question["about"] == "b"
	help_bubble_b.visible = question["about"] == "a"
	mood_change_a.hide()
	mood_change_b.hide()

	time_left = ROUND_SECONDS
	waiting_for_answer = true


func _on_option_pressed(index: int) -> void:
	if waiting_for_answer:
		_finish_round(option_buttons[index].text)


## Checks the answer, changes mood and score, then moves on.
func _finish_round(answer: String) -> void:
	waiting_for_answer = false
	profile_popup.hide()  # in case time ran out while a profile was open
	help_bubble_a.hide()
	help_bubble_b.hide()
	for button in option_buttons:
		button.disabled = true

	var question: Dictionary = questions[round_index]
	var is_right: bool = answer == question["correct"]

	# Colour the buttons: the right answer turns green,
	# and a wrong pick turns red.
	for button in option_buttons:
		if button.text == question["correct"]:
			_color_button(button, RIGHT_COLOR)
		elif button.text == answer:
			_color_button(button, WRONG_COLOR)
	var mood_change: int = MOOD_RIGHT if is_right else MOOD_WRONG

	# Only the cat the question is about reacts.
	var about_name: String
	var mood_change_label: Label
	if question["about"] == "a":
		mood_a = clampi(mood_a + mood_change, 0, 100)
		about_name = cat_a["name"]
		mood_change_label = mood_change_a
	else:
		mood_b = clampi(mood_b + mood_change, 0, 100)
		about_name = cat_b["name"]
		mood_change_label = mood_change_b

	# Show "+20" or "-15" next to the cat whose mood just changed.
	# "%+d" writes a number with its plus or minus sign.
	mood_change_label.text = "%+d" % mood_change
	mood_change_label.add_theme_color_override(
		"font_color", MOOD_UP_COLOR if is_right else MOOD_DOWN_COLOR
	)
	mood_change_label.show()

	if is_right:
		score += SCORE_RIGHT + SCORE_PER_SECOND_LEFT * int(time_left)
		question_label.text = "Right! %s feels remembered." % about_name
	elif answer == "":
		question_label.text = "Too slow! The answer was: %s." % question["correct"]
	else:
		question_label.text = "Oops, that's not it. The answer was: %s." % question["correct"]

	_update_display()

	# Wait a moment so the player can read the message.
	await get_tree().create_timer(FEEDBACK_SECONDS).timeout

	round_index += 1
	if round_index < questions.size():
		_start_round()
	else:
		_end_date()


## Paints an answered (disabled) button in one colour with white text.
func _color_button(button: Button, color: Color) -> void:
	# Copy the button's normal look and change only its background colour.
	var style := button.get_theme_stylebox("normal").duplicate() as StyleBoxFlat
	style.bg_color = color
	button.add_theme_stylebox_override("disabled", style)
	button.add_theme_color_override("font_disabled_color", Color.WHITE)


## Removes the colour again, so the button looks normal in the next round.
func _clear_button_color(button: Button) -> void:
	button.remove_theme_stylebox_override("disabled")
	button.remove_theme_color_override("font_disabled_color")


## Shows the current moods and score on screen.
func _update_display() -> void:
	mood_label_a.text = "%s's mood: %d%%" % [cat_a["name"], mood_a]
	mood_label_b.text = "%s's mood: %d%%" % [cat_b["name"], mood_b]
	mood_bar_a.value = mood_a
	mood_bar_b.value = mood_b
	score_label.text = "Score: %d" % score


## Opens one cat's profile card on top of the date.
## The timer keeps running while it is open, so looking things up costs time.
func _show_profile(cat: Dictionary) -> void:
	profile_card.setup(cat)
	profile_card.show_as_profile()
	profile_popup.show()


func _on_profile_bubble_a_pressed() -> void:
	_show_profile(cat_a)


func _on_profile_bubble_b_pressed() -> void:
	_show_profile(cat_b)


func _on_profile_close_button_pressed() -> void:
	profile_popup.hide()


## Works out how the date went and opens the result screen.
func _end_date() -> void:
	var a_loved_it: bool = mood_a >= GameState.LOVED_IT_MOOD
	var b_loved_it: bool = mood_b >= GameState.LOVED_IT_MOOD

	var outcome: String = "Failed"
	if a_loved_it and b_loved_it:
		outcome = "Great"
	elif a_loved_it or b_loved_it:
		outcome = "Okay"

	GameState.mood_a = mood_a
	GameState.mood_b = mood_b
	GameState.score = score
	GameState.last_outcome = outcome

	# Shows up in Godot's Output panel, handy for checking while testing.
	print("Date outcome: %s  (%s %d%%, %s %d%%, score %d)" % [
		outcome, cat_a["name"], mood_a, cat_b["name"], mood_b, score,
	])

	get_tree().change_scene_to_file("res://scenes/result.tscn")
