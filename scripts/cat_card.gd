extends PanelContainer
## One cat card: portrait, name, traits, willingness and a Select button.
##
## The card does not decide anything itself. When its button is pressed it
## sends out the "select_pressed" signal, and the screen that owns the card
## (the cat picker) decides what happens.

## Sent when the Select button is pressed. Carries this card's cat.
signal select_pressed(cat: Dictionary)

## The cat this card is showing.
var cat: Dictionary = {}

@onready var portrait: TextureRect = $Margin/Rows/Portrait
@onready var name_label: Label = $Margin/Rows/NameLabel
@onready var personality_label: Label = $Margin/Rows/PersonalityLabel
@onready var traits_label: Label = $Margin/Rows/TraitsLabel
@onready var likes_label: Label = $Margin/Rows/LikesLabel
@onready var willingness_label: Label = $Margin/Rows/WillingnessLabel
@onready var willingness_bar: ProgressBar = $Margin/Rows/WillingnessBar
@onready var select_button: Button = $Margin/Rows/SelectButton


## Fills the card with one cat's data.
## Call this after the card has been added to a screen with add_child().
func setup(new_cat: Dictionary) -> void:
	cat = new_cat
	portrait.texture = load(cat["image"])
	name_label.text = "%s, age %d" % [cat["name"], cat["age"]]
	personality_label.text = cat["personality"]
	# join() glues the list of traits into one text: "Lazy, Foodie, Shy"
	traits_label.text = ", ".join(PackedStringArray(cat["traits"]))
	likes_label.text = "Likes: " + ", ".join(PackedStringArray(cat["likes"]))
	willingness_label.text = "Willingness %d%%" % cat["willingness"]
	willingness_bar.value = cat["willingness"]


## Turns the card into a "just looking" card for screens where the cat is
## already picked: no Select button, and a bigger portrait.
func show_as_profile() -> void:
	select_button.hide()
	portrait.custom_minimum_size.y = 315


## Changes how the card looks when its cat is picked or not picked.
func set_selected(is_selected: bool) -> void:
	if is_selected:
		select_button.text = "Selected"
		self_modulate = Color(1, 0.8, 0.88)  # pink tint on the card background
	else:
		select_button.text = "Select"
		self_modulate = Color(1, 1, 1)  # normal colour


func _on_select_button_pressed() -> void:
	select_pressed.emit(cat)
