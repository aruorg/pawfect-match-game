extends Control
## Match check screen: shows the two picked cats and how well they fit.

## Hearts are drawn as circles for now (no heart picture yet).
const HEART_SIZE := Vector2(78, 78)
const HEART_FILLED_COLOR := Color(0.851, 0.31, 0.561)
const HEART_BORDER_COLOR := Color(0.557, 0.165, 0.388)

@onready var card_a = $CardA
@onready var card_b = $CardB
@onready var hearts_row: HBoxContainer = $InfoPanel/Rows/Hearts
@onready var shared_label: Label = $InfoPanel/Rows/SharedLabel
@onready var clash_label: Label = $InfoPanel/Rows/ClashLabel
@onready var willingness_label: Label = $InfoPanel/Rows/WillingnessLabel


func _ready() -> void:
	# Normally the cat picker has stored a pair. If this screen is run on its
	# own for testing (F6 in the editor), use the first two cats instead.
	if GameState.cat_a.is_empty() or GameState.cat_b.is_empty():
		GameState.cat_a = CatData.CATS[0]
		GameState.cat_b = CatData.CATS[1]

	var cat_a: Dictionary = GameState.cat_a
	var cat_b: Dictionary = GameState.cat_b

	card_a.setup(cat_a)
	card_a.show_as_profile()
	card_b.setup(cat_b)
	card_b.show_as_profile()

	# Ask the shared formula how well these two fit.
	var result: Dictionary = Compatibility.check(cat_a, cat_b)
	_show_hearts(result["hearts"])
	shared_label.text = _as_text(result["shared"], "Nothing in common")
	clash_label.text = _as_text(result["clashes"], "No clashes")
	willingness_label.text = "%s %d%%, %s %d%%" % [
		cat_a["name"], cat_a["willingness"],
		cat_b["name"], cat_b["willingness"],
	]


## Draws the row of hearts: the first "filled_count" are filled, the rest empty.
func _show_hearts(filled_count: int) -> void:
	for i in Compatibility.MAX_HEARTS:
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


## Turns a list into one line of text, or a fallback text if the list is empty.
func _as_text(items: Array, text_if_empty: String) -> String:
	if items.is_empty():
		return text_if_empty
	return ", ".join(PackedStringArray(items))


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/cat_picker.tscn")


func _on_start_date_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/date.tscn")
