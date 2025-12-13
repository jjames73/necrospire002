extends Node

@export_file("*.tscn") var next_scene: String

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):  # Space
		_load_next()

func _load_next():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
