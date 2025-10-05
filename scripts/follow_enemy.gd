extends CharacterBody2D

# Enemy settings
@export var speed: float = 400.0
@export var stop_distance: float = 200.0  # enemy stops when near player

# Find player (must be in 'player' group)
@onready var player: Node2D = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		if player == null:
			print("⚠️ Player not found in group 'player'!")
			velocity = Vector2.ZERO
			move_and_slide()
			return

	var direction: Vector2 = position.direction_to(player.global_position)
	var distance: float = position.distance_to(player.global_position)

	if distance > stop_distance:
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	if direction.x != 0:
		$AnimatedSprite2D.flip_h = direction.x < 0

	if velocity.length() > 0:
		if not $AnimatedSprite2D.is_playing():
			$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("idle")
		
