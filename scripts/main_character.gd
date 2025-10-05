extends CharacterBody2D

@export var walk_SPEED = 150.0
@export var run_SPEED = 300.0
@export_range(0, 1) var acceleration = 0.1
@export_range(0, 1) var deceleration = 0.1
@export var jump_force = -400.0
@export_range(0, 1) var decelerate_on_jump_release = 0.5

var isSAttacking = false
var is_dead: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D

# store original offset of attack relative to player
var attack_offset: Vector2

func _ready() -> void:
	attack_offset = attack_area.position
	attack_shape.disabled = true

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# --- Gravity ---
	velocity += get_gravity() * delta

	# --- Jump ---
	if Input.is_action_just_pressed("jump") and is_on_floor() and not isSAttacking:
		velocity.y = jump_force
	if Input.is_action_just_released("jump") and velocity.y < 0 and not isSAttacking:
		velocity.y *= decelerate_on_jump_release

	# --- Movement ---
	var speed = run_SPEED if Input.is_action_pressed("dash") and not isSAttacking else walk_SPEED
	var direction = Input.get_axis("left", "right")

	# --- Attack ---
	if Input.is_action_just_pressed("attack") and not isSAttacking:
		isSAttacking = true
		attack_shape.disabled = false
		velocity.x = 0
		animated_sprite.play("attack-s")

	# --- Walk/Idle ---
	if not isSAttacking:
		if direction != 0:
			velocity.x = move_toward(velocity.x, direction * speed, speed * acceleration)
			animated_sprite.play("walk")
			animated_sprite.flip_h = direction < 0
		else:
			velocity.x = move_toward(velocity.x, 0, walk_SPEED * deceleration)
			animated_sprite.play("idle")
			attack_shape.disabled = true

	# --- Move AttackArea in front of player without flipping collision ---
	attack_area.position.x = attack_offset.x if not animated_sprite.flip_h else -attack_offset.x
	attack_area.position.y = attack_offset.y

	move_and_slide()

# --- Reset attack when animation finishes ---
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "attack-s":
		attack_shape.disabled = true
		isSAttacking = false

# --- Player death ---
func die() -> void:
	is_dead = true
	print("💀 Player died!")
	animated_sprite.play("death")
	await animated_sprite.animation_finished
	get_tree().reload_current_scene()
