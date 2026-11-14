extends Control
## Studio hub screen: shows the cats in their rooms and leads to the cat picker.

## How big each cat is drawn in the studio, in pixels (width, height).
const CAT_SIZE := Vector2(135, 144)

## Where each cat stands, by cat name. The numbers are the top-left corner
## of the cat's picture (x from the left edge, y from the top edge).
const CAT_POSITIONS := {
	"Pepper": Vector2(495, 419),
	"Mochi": Vector2(1050, 419),
	"Biscuit": Vector2(780, 713),
}

# "@onready" fetches these nodes from the scene once the screen has loaded.
@onready var cats_layer: Control = $Cats
@onready var treats_label: Label = $TreatsLabel
@onready var xp_label: Label = $XpLabel


func _ready() -> void:
	treats_label.text = "Treats: %d" % GameState.treats
	xp_label.text = "Level %d (XP %d)" % [GameState.get_level(), GameState.xp]

	# Go through the cat list and put each cat into the studio.
	for cat in CatData.CATS:
		_add_cat(cat)


## Creates one clickable cat picture with a name tag above it.
func _add_cat(cat: Dictionary) -> void:
	# Skip cats that have no spot in the studio yet.
	if not CAT_POSITIONS.has(cat["name"]):
		return

	var cat_button := TextureButton.new()
	cat_button.texture_normal = load(cat["image"])
	# These two lines let the picture shrink to CAT_SIZE without being squashed.
	cat_button.ignore_texture_size = true
	cat_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	cat_button.position = CAT_POSITIONS[cat["name"]]
	cat_button.size = CAT_SIZE
	cat_button.pressed.connect(_open_cat_picker)
	cats_layer.add_child(cat_button)

	var name_tag := Label.new()
	name_tag.text = cat["name"]
	name_tag.add_theme_font_size_override("font_size", 24)
	name_tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_tag.position = cat_button.position + Vector2(0, -45)
	name_tag.size = Vector2(CAT_SIZE.x, 36)
	cats_layer.add_child(name_tag)


func _open_cat_picker() -> void:
	get_tree().change_scene_to_file("res://scenes/cat_picker.tscn")
