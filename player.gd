extends CharacterBody2D

@export var speed: float = 100.0
@export var score_label: Label
@export var lives_label: Label
@export var max_health: int = 3
@export var invincibility_duration: float = 2.0
@export var souls_required_to_open: int = 200
@export var door_sprite: Sprite2D
@export var score_message: Label
@export_file("*.tscn") var next_level_scene: String

var dir: Vector2 = Vector2.ZERO
var queued: Vector2 = Vector2.ZERO
var score: int = 0
var current_health: int = 0

var is_invincible: bool = false
var invincibility_time_left: float = 0.0

var in_door_area: bool = false      # true when standing in DoorZone

@onready var rc_up: RayCast2D = $rc_up
@onready var rc_down: RayCast2D = $rc_down
@onready var rc_left: RayCast2D = $rc_left
@onready var rc_right: RayCast2D = $rc_right

@onready var pellet_map: TileMap = $"../PelletTileMap"

var spawn_position: Vector2


func _ready() -> void:
	spawn_position = global_position
	current_health = max_health

	_update_score_label()
	_update_lives_label()


func _physics_process(delta: float) -> void:
	_handle_input()

	if _can_move(queued):
		dir = queued

	if not _can_move(dir):
		dir = Vector2.ZERO

	velocity = dir * speed
	move_and_slide()

	_check_for_pellet()

	# invincibility timer
	if is_invincible:
		invincibility_time_left -= delta
		if invincibility_time_left <= 0.0:
			is_invincible = false

	# door interaction: press Space (ui_accept) while in door zone
	# and score is high enough
	if in_door_area and score >= souls_required_to_open and Input.is_action_just_pressed("ui_accept"):
		print("Door conditions met: opening door...")
		_open_door()


func _handle_input() -> void:
	if Input.is_action_pressed("ui_right"):
		queued = Vector2.RIGHT
	elif Input.is_action_pressed("ui_left"):
		queued = Vector2.LEFT
	elif Input.is_action_pressed("ui_up"):
		queued = Vector2.UP
	elif Input.is_action_pressed("ui_down"):
		queued = Vector2.DOWN


func _can_move(direction: Vector2) -> bool:
	if direction == Vector2.ZERO:
		return false

	match direction:
		Vector2.UP:
			return not rc_up.is_colliding()
		Vector2.DOWN:
			return not rc_down.is_colliding()
		Vector2.LEFT:
			return not rc_left.is_colliding()
		Vector2.RIGHT:
			return not rc_right.is_colliding()

	return false


# ------------------------------------------------------------
# SOUL SCORE
# ------------------------------------------------------------
func add_soul(amount: int = 1) -> void:
	score += amount
	_update_score_label()
	
	if score >= souls_required_to_open:
		_can_leave()
		score_message.text = "Press Space to open door"
		score_message.visible = true
		
func _update_score_label() -> void:
	if score_label:
		score_label.text = "Souls: " + str(score)


# ------------------------------------------------------------
# LIVES DISPLAY
# ------------------------------------------------------------
func _update_lives_label() -> void:
	if lives_label:
		lives_label.text = "Lives: " + str(current_health)


# ------------------------------------------------------------
# PELLET CHECK (TileMap pellets)
# ------------------------------------------------------------
func _check_for_pellet() -> void:
	if pellet_map == null:
		return

	var local_pos: Vector2 = pellet_map.to_local(global_position)
	var tile_pos: Vector2i = pellet_map.local_to_map(local_pos)
	var source_id := pellet_map.get_cell_source_id(0, tile_pos)

	if source_id != -1:
		pellet_map.erase_cell(0, tile_pos)
		add_soul(1)
		print("PELLET EATEN! Score:", score)


# ------------------------------------------------------------
# OPTIONAL: for Area2D soul_pellet (signal "collected")
# ------------------------------------------------------------
func _on_soul_pellet_collected() -> void:
	add_soul(1)


# ------------------------------------------------------------
# HEALTH / DAMAGE WITH INVINCIBILITY
# ------------------------------------------------------------
func take_damage(amount: int = 1) -> void:
	if is_invincible:
		return

	current_health -= amount
	_update_lives_label()
	print("take_damage: new HP =", current_health, "/", max_health)

	is_invincible = true
	invincibility_time_left = invincibility_duration

	if current_health <= 0:
		_die()


func _die() -> void:
	print("Player died, restarting level...")
	get_tree().reload_current_scene()


# ------------------------------------------------------------
# DOOR INTERACTION (DoorZone is an Area2D with CollisionShape2D)
# ------------------------------------------------------------
func _open_door() -> void:
	get_tree().change_scene_to_file(next_level_scene)
		
# Called when the player enters the door's Area2D (DoorZone)
func _on_door_zone_body_entered(body: Node) -> void:
	if body == self:
		in_door_area = true
		print("Player entered door zone. Score =", score, " / required =", souls_required_to_open)

# Called when the player exits the door's Area2D (DoorZone)
func _on_door_zone_body_exited(body: Node) -> void:
	if body == self:
		in_door_area = false
		print("Player left door zone")
		
func _can_leave() -> void:
	if door_sprite:
		door_sprite.modulate = Color(1.0, 1.0, 0.0)  # yellow
		
