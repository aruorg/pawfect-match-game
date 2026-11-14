extends Control
## Match check screen. Stub for now: only a title and a button.


func _on_next_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/date.tscn")
