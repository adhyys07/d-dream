extends CharacterBody2D

@export var speed: float = 80.0
@export var attack_range: float = 60.0
@export var attack_damage: int = 6
@export var max_health: int = 30

var health: int
var player: Node2D = null
var is_attacking := false
var facing_right := true

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $Area2D
@onready var cooldown: Timer = $AttackCooldown

func _ready():
	health = max_health
	attack_area.body_entered.connect(_on_attack_area_entered)
	attack_area.body_exited.connect(_on_attack_area_exited)

func _physics_process(delta: float):
	if not player or is_attacking:
		velocity = Vector2.ZERO
		anim.play("Walk")  # idle looks like subtle walk
		move_and_slide()
		return

	# Direction vector toward player
	var direction = (player.global_position - global_position).normalized()

	# Flip sprite horizontally based on movement direction
	if direction.x != 0:
		facing_right = direction.x > 0
		anim.flip_h = not facing_right  # flip horizontally when facing left

	# Check attack range
	var dist = global_position.distance_to(player.global_position)
	if dist <= attack_range and cooldown.is_stopped():
		start_attack()
		return

	# Always chase player
	velocity = direction * speed
	if not is_attacking:
		anim.play("Walk")

	move_and_slide()

func start_attack():
	is_attacking = true
	velocity = Vector2.ZERO
	anim.play("Attack")
	cooldown.start()
	await get_tree().create_timer(0.4).timeout
	if player and global_position.distance_to(player.global_position) <= attack_range:
		if player.has_method("take_damage"):
			player.take_damage(attack_damage)
	await get_tree().create_timer(0.6).timeout
	is_attacking = false

func take_damage(amount: int):
	health -= amount
	anim.play("Hurt")
	if health <= 0:
		die()

func die():
	anim.play("Death")
	await anim.animation_finished
	queue_free()

func _on_attack_area_entered(body):
	if body.is_in_group("player"):
		player = body

func _on_attack_area_exited(body):
	if body == player:
		player = null
