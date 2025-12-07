extends CharacterBody2D

@export var chase_speed: float = 70.0          # speed while chasing player
@export var return_speed: float = 40.0         # slower speed when going home
@export var chase_radius: float = 120.0        # start chasing if within this distance
@export var stop_chase_radius: float = 140.0   # stop chasing when player is this far
@export var player_path: NodePath              # assign Player in the inspector

var player: Node2D = null
var home_position: Vector2


func _ready() -> void:
	# Remember where the ghost started
	home_position = global_position

	# Get player reference
	if player_path != NodePath():
		player = get_node(player_path)


func _physics_process(delta: float) -> void:
	if player == null:
		return

	var to_player: Vector2 = player.global_position - global_position
	var dist_to_player: float = to_player.length()

	var target_pos: Vector2
	var current_speed: float

	# --- Decide what to do ---
	if dist_to_player <= chase_radius:
		# Player is close → chase
		target_pos = player.global_position
		current_speed = chase_speed
	elif dist_to_player > stop_chase_radius and global_position.distance_to(home_position) > 2.0:
		# Player is far → return home
		target_pos = home_position
		current_speed = return_speed
	else:
		# Idle (at home and player far away)
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# --- Move towards target (player or home) ---
	var dir: Vector2 = (target_pos - global_position).normalized()
	velocity = dir * current_speed
	move_and_slide()
