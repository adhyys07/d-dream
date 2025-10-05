extends CharacterBody2D

@export var walk_SPEED = 150.0
@export var run_SPEED = 300
@export_range(0, 1) var acceleration = 0.1
@export_range(0, 1) var deceleration = 0.1
@export var jump_force = -400
@export_range(0, 1) var decelerate_on_jump_release = 0.5 
const JUMP_VELOCITY = -400.0

@onready var animated_sprite = $AnimatedSprite2D

var is_dead: bool = false

func _physics_process(delta: float) -> void:
	if is_dead:
		return  # stop movement after death

	# Gravity
	velocity += get_gravity() * delta

	# --- Jump handling ---
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force 

	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= decelerate_on_jump_release

	# --- Movement ---
	var speed
	if Input.is_action_pressed("dash"):
		speed = run_SPEED
	else:
		speed = walk_SPEED

	var direction := Input.get_axis("left", "right")

	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, speed * acceleration)
		animated_sprite.play("walk")
		animated_sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, walk_SPEED * deceleration)
		animated_sprite.play("idle")

	move_and_slide()

# --- Handle player death ---
func die() -> void:
	is_dead = true
	print("💀 Player died!")
	animated_sprite.play("death") # optional animation
	await animated_sprite.animation_finished
	get_tree().reload_current_scene()  # restart the level
