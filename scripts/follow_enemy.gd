extends CharacterBody2D

# --- Enemy Settings ---
@export var speed: float = 200.0
@export var stop_distance: float = 100.0  # stops when near player
@export var gravity: float = 800.0        # gravity for enemy

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

	# --- Horizontal movement only ---
	var to_player_x = player.global_position.x - global_position.x
	if abs(to_player_x) > stop_distance:
		var direction_x = sign(to_player_x)  # +1 or -1
		velocity.x = direction_x * speed
	else:
		velocity.x = 0

	# --- Gravity ---
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# --- Move the enemy ---
	move_and_slide()

	# --- Sprite flipping ---
	if velocity.x != 0:
		$AnimatedSprite2D.flip_h = velocity.x < 0

	# --- Animation ---
	if abs(velocity.x) > 0.1:
		if $AnimatedSprite2D.animation != "walk":
			$AnimatedSprite2D.play("walk")
	else:
		if $AnimatedSprite2D.animation != "idle":
			$AnimatedSprite2D.play("idle")
