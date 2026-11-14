extends Control
## Cat picker screen: shows a card for every cat and lets the player pick two.

## The card scene. "preload" loads it once, ready to be copied for each cat.
const CAT_CARD_SCENE := preload("res://scenes/cat_card.tscn")

## The cats the player has picked so far (never more than two).
var selected_cats: Array = []

## All the cards on screen, so their look can be updated after each pick.
var cards: Array = []

@onready var cards_row: HBoxContainer = $Panel/Cards
@onready var slot_a_picture: TextureRect = $Tray/SlotAPicture
@onready var slot_a_label: Label = $Tray/SlotALabel
@onready var slot_b_picture: TextureRect = $Tray/SlotBPicture
@onready var slot_b_label: Label = $Tray/SlotBLabel
@onready var check_match_button: Button = $Tray/CheckMatchButton


func _ready() -> void:
	# Make one card per cat and listen for its Select button.
	for cat in CatData.CATS:
		var card = CAT_CARD_SCENE.instantiate()
		cards_row.add_child(card)
		card.setup(cat)
		card.select_pressed.connect(_on_card_select_pressed)
		cards.append(card)
	_refresh()


## Runs when any card's Select button is pressed.
func _on_card_select_pressed(cat: Dictionary) -> void:
	if selected_cats.has(cat):
		# Already picked: unpick it.
		selected_cats.erase(cat)
	elif selected_cats.size() < 2:
		# Room for one more: pick it.
		selected_cats.append(cat)
	else:
		# Two are already picked: the new cat replaces the second one.
		selected_cats[1] = cat
	_refresh()


## Updates everything on screen to match the current picks.
func _refresh() -> void:
	for card in cards:
		card.set_selected(selected_cats.has(card.cat))

	_show_slot(slot_a_picture, slot_a_label, 0)
	_show_slot(slot_b_picture, slot_b_label, 1)

	var pair_ready := selected_cats.size() == 2
	check_match_button.disabled = not pair_ready
	check_match_button.text = "Check match" if pair_ready else "Pick 2 cats"


## Shows one picked cat in a tray slot, or "Empty" if that slot has no cat.
func _show_slot(picture: TextureRect, label: Label, index: int) -> void:
	if index < selected_cats.size():
		var cat: Dictionary = selected_cats[index]
		picture.texture = load(cat["image"])
		label.text = cat["name"]
	else:
		picture.texture = null
		label.text = "Empty"


func _on_check_match_button_pressed() -> void:
	# Remember the pair so the next screens know which cats are on the date.
	GameState.cat_a = selected_cats[0]
	GameState.cat_b = selected_cats[1]
	get_tree().change_scene_to_file("res://scenes/match_check.tscn")


func _on_close_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/studio.tscn")
