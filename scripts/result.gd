extends Control
## Date result screen: shows how the date went and gives the rewards.

## What each outcome looks like and what it is worth.
const OUTCOMES := {
	"Great": {
		"title": "GREAT!", "color": Color(0.761, 0.212, 0.478),
		"hearts": 3, "treats": 20, "xp": 80,
	},
	"Okay": {
		"title": "OKAY", "color": Color(0.557, 0.165, 0.388),
		"hearts": 2, "treats": 10, "xp": 40,
	},
	"Failed": {
		"title": "FAILED", "color": Color(0.353, 0.165, 0.267),
		"hearts": 0, "treats": 0, "xp": 15,
	},
}

const MAX_HEARTS := 3
## Hearts are drawn as circles for now (no heart picture yet).
const HEART_SIZE := Vector2(66, 66)
const HEART_FILLED_COLOR := Color(0.851, 0.31, 0.561)
const HEART_BORDER_COLOR := Color(0.557, 0.165, 0.388)

@onready var rating_label: Label = $Panel/Rows/RatingLabel
@onready var hearts_row: HBoxContainer = $Panel/Rows/Hearts
@onready var picture_a: TextureRect = $Panel/Rows/Cats/CatBoxA/Margin/Row/Picture
@onready var name_label_a: Label = $Panel/Rows/Cats/CatBoxA/Margin/Row/Texts/NameLabel
@onready var verdict_label_a: Label = $Panel/Rows/Cats/CatBoxA/Margin/Row/Texts/VerdictLabel
@onready var picture_b: TextureRect = $Panel/Rows/Cats/CatBoxB/Margin/Row/Picture
@onready var name_label_b: Label = $Panel/Rows/Cats/CatBoxB/Margin/Row/Texts/NameLabel
@onready var verdict_label_b: Label = $Panel/Rows/Cats/CatBoxB/Margin/Row/Texts/VerdictLabel
@onready var message_label: Label = $Panel/Rows/MessageLabel
@onready var score_label: Label = $Panel/Rows/ScoreLabel
@onready var rewards_label: Label = $Panel/Rows/RewardsLabel
@onready var totals_label: Label = $Panel/Rows/TotalsLabel


func _ready() -> void:
	# If this screen is run on its own for testing (F6), make up an "Okay" date.
	if GameState.last_outcome == "":
		GameState.cat_a = CatData.CATS[0]
		GameState.cat_b = CatData.CATS[1]
		GameState.mood_a = 70
		GameState.mood_b = 45
		GameState.last_outcome = "Okay"

	var cat_a: Dictionary = GameState.cat_a
	var cat_b: Dictionary = GameState.cat_b
	var outcome: String = GameState.last_outcome
	var info: Dictionary = OUTCOMES[outcome]

	rating_label.text = info["title"]
	rating_label.add_theme_color_override("font_color", info["color"])
	_show_hearts(info["hearts"])

	picture_a.texture = load(cat_a["image"])
	name_label_a.text = cat_a["name"]
	verdict_label_a.text = _verdict(GameState.mood_a, outcome)
	picture_b.texture = load(cat_b["image"])
	name_label_b.text = cat_b["name"]
	verdict_label_b.text = _verdict(GameState.mood_b, outcome)

	# A failed pair needs a break before they can be matched again.
	if outcome == "Failed":
		GameState.start_cooldown(cat_a, cat_b)

	message_label.text = _message(cat_a, cat_b, outcome)
	score_label.text = "Score: %d" % GameState.score

	# Give the rewards. The level is checked before and after,
	# to notice when the player has just reached a new level.
	var level_before: int = GameState.get_level()
	GameState.treats += info["treats"]
	GameState.xp += info["xp"]
	var level_after: int = GameState.get_level()

	rewards_label.text = "+%d treats     +%d XP" % [info["treats"], info["xp"]]
	totals_label.text = "You now have %d treats  -  Level %d (XP %d)" % [
		GameState.treats, level_after, GameState.xp,
	]
	if level_after > level_before:
		totals_label.text += "\nLevel up! You reached level %d." % level_after


## What one cat thought of the date, with its final mood.
func _verdict(mood: int, outcome: String) -> String:
	var text: String
	if mood >= GameState.LOVED_IT_MOOD:
		text = "Loved it"
	elif outcome == "Okay":
		text = "Not sure..."
	else:
		text = "Not for me"
	return "%s (mood %d%%)" % [text, mood]


## The sentence that explains the outcome.
func _message(cat_a: Dictionary, cat_b: Dictionary, outcome: String) -> String:
	if outcome == "Great":
		return "Both cats loved the date!"
	if outcome == "Okay":
		# Work out which cat loved it and which one was unsure.
		var happy_cat: Dictionary = cat_a
		var unsure_cat: Dictionary = cat_b
		if GameState.mood_b >= GameState.LOVED_IT_MOOD:
			happy_cat = cat_b
			unsure_cat = cat_a
		return "%s loved it, but %s was not sure." % [happy_cat["name"], unsure_cat["name"]]
	return "No second date. %s and %s need a break of %s before they can be matched again." % [
		cat_a["name"], cat_b["name"], GameState.format_time(GameState.COOLDOWN_SECONDS),
	]


## Draws the row of hearts: the first "filled_count" are filled, the rest empty.
func _show_hearts(filled_count: int) -> void:
	for i in MAX_HEARTS:
		var style := StyleBoxFlat.new()
		style.set_corner_radius_all(int(HEART_SIZE.x / 2))
		style.set_border_width_all(4)
		style.border_color = HEART_BORDER_COLOR
		if i < filled_count:
			style.bg_color = HEART_FILLED_COLOR
		else:
			style.bg_color = Color(0, 0, 0, 0)  # see-through = empty heart

		var heart := Panel.new()
		heart.custom_minimum_size = HEART_SIZE
		heart.add_theme_stylebox_override("panel", style)
		hearts_row.add_child(heart)


func _on_to_studio_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/studio.tscn")


func _on_new_pair_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/cat_picker.tscn")
