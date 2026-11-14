extends Node2D
## Starting point of the game. For now it opens the studio right away.
## Later this scene can become the title screen.


func _ready() -> void:
	# "call_deferred" waits until this scene has finished loading
	# before switching, which Godot requires for scene changes here.
	get_tree().change_scene_to_file.call_deferred("res://scenes/studio.tscn")
