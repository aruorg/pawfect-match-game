extends Control
## Date screen (cafe). Stub for now: only a title and a button.


func _on_next_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/result.tscn")
