extends Node2D

var button_type = null

func _on_start_pressed() -> void:
	button_type = "start"
	get_tree().change_scene_to_file("res://Scenes/Level1.tscn")


func _on_instructions_pressed() -> void:
	button_type = "instructions"
	get_tree().change_scene_to_file("res://Scenes/instructions.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
