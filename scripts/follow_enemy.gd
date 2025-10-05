extends CharacterBody2D

# --- Enemy Settings ---
@export var speed: float = 200.0
@export var stop_distance: float = 100.0  # stops when near player

# --- Player Reference ---
@onready var player: Node2D = null

func _ready() -> void:
	# Find the player in the scene by group
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		push_warning("⚠️ Player not found in 'player' group!")

func _physics_process(delta: float) -> void:
	# Validate player reference
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		if player == null:
			velocity = Vector2.ZERO
			move_and_slide()
			return

	# Direction and distance to player
	var to_player: Vector2 = player.global_position - global_position
	var distance: float = to_player.length()

	# Move enemy only if player is beyond stop_distance
	if distance > stop_distance:
		var direction: Vector2 = to_player.normalized()
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO

	# Move the enemy
	move_and_slide()

	# --- Sprite flipping ---
	if velocity.x != 0:
		$AnimatedSprite2D.flip_h = velocity.x < 0

	# --- Animation ---
	if velocity.length() > 0.1:
		if $AnimatedSprite2D.animation != "walk":
			$AnimatedSprite2D.play("walk")
	else:
		if $AnimatedSprite2D.animation != "idle":
			$AnimatedSprite2D.play("idle")
