extends Control
## Date result screen. Stub for now: only a title and a button.


func _on_next_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/studio.tscn")
