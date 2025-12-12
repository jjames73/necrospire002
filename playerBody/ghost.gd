extends CharacterBody2D

@export var chase_speed: float = 70.0
@export var return_speed: float = 40.0
@export var player_path: NodePath

var player: Node2D = null
var home_position: Vector2
var is_chasing: bool = false

@onready var chase_area: Area2D = $ChaseArea
@onready var hurt_area: Area2D = $HurtArea


func _ready() -> void:
	home_position = global_position

	if player_path != NodePath():
		player = get_node(player_path)

	# Detect entering/exiting chase zone
	chase_area.body_entered.connect(_on_chase_area_enter)
	chase_area.body_exited.connect(_on_chase_area_exit)

	# Detect collisions that damage player
	hurt_area.body_entered.connect(_on_hurt_area_enter)


func _physics_process(delta: float) -> void:
	if player == null:
		return

	if is_chasing:
		# Move toward player
		var dir = (player.global_position - global_position).normalized()
		velocity = dir * chase_speed
	else:
		# Return home when NOT chasing
		var dist_home = global_position.distance_to(home_position)
		if dist_home > 3.0:
			var dir = (home_position - global_position).normalized()
			velocity = dir * return_speed
		else:
			velocity = Vector2.ZERO

	move_and_slide()


# -------------------------------
# CHASE LOGIC (Area2D-based)
# -------------------------------
func _on_chase_area_enter(body):
	if body == player:
		is_chasing = true
		# print("Ghost sees the player!")


func _on_chase_area_exit(body):
	if body == player:
		is_chasing = false
		# print("Ghost lost the player.")


# -------------------------------
# DAMAGE LOGIC
# -------------------------------
func _on_hurt_area_enter(body):
	if body == player:
		if body.has_method("take_damage"):
			body.take_damage(1)
