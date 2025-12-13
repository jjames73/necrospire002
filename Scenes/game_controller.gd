extends Node

@export var pause_menu: CanvasItem  

var is_paused: bool = false

func _ready() -> void:
	#dont touch
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Hide pause menu at start
	if pause_menu:
		pause_menu.visible = false


func _process(_delta: float) -> void:
	# Toggle pause
	if Input.is_action_just_pressed("pause"):
		_toggle_pause()

	# Restart level
	if Input.is_action_just_pressed("restart"):
		_restart_level()


func _toggle_pause() -> void:
	is_paused = not is_paused
	get_tree().paused = is_paused

	if pause_menu:
		pause_menu.visible = is_paused

	print("Paused:", is_paused)


func _restart_level() -> void:
	# Make sure we unpause before reloading
	get_tree().paused = false
	is_paused = false
	print("Restarting level...")
	get_tree().reload_current_scene()
