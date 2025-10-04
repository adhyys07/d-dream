extends CharacterBody2D

# Enemy stats
@export var speed: float = 150.0

# Store the player node reference. This assumes the player is in the 'player' group.
@onready var player = get_tree().get_first_node_in_group("player")

# --- Movement Logic ---
func _physics_process(delta):
	# Check if the player exists in the scene
	if player == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# 1. Calculate the direction vector from the enemy to the player.
	# position.direction_to() returns a normalized (length=1) Vector2.
	var direction: Vector2 = position.direction_to(player.global_position)

	# 2. Set the velocity based on the direction and speed.
	velocity = direction * speed

	# 3. Use move_and_slide for physics-based movement and collision handling.
	move_and_slide()
	
	# Optional: Flip the sprite to face the player.
	# Check if the enemy is trying to move left or right.
	if direction.x != 0:
		$Sprite2D.flip_h = direction.x < 0
