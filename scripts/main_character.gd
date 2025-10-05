extends CharacterBody2D

@export var walk_SPEED = 150.0
@export var run_SPEED = 300.0
@export_range(0, 1) var acceleration = 0.1
@export_range(0, 1) var deceleration = 0.1
@export var jump_force = -400.0
@export_range(0, 1) var decelerate_on_jump_release = 0.5

var isSAttacking: bool = false
var is_dead: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D


var attack_offset: Vector2

func _ready() -> void:
	attack_offset = attack_area.position
	attack_shape.disabled = true
	$AttackArea2/CollisionShape2D.disabled = true


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor() and not isSAttacking:
		velocity.y = jump_force
	if Input.is_action_just_released("jump") and velocity.y < 0 and not isSAttacking:
		velocity.y *= decelerate_on_jump_release

	var speed = run_SPEED if Input.is_action_pressed("dash") and not isSAttacking else walk_SPEED
	var direction = Input.get_axis("left", "right")

	if Input.is_action_just_pressed("attack") and not isSAttacking:
		isSAttacking = true
		attack_shape.disabled = false
		$AttackArea2/CollisionShape2D.disabled = false
		animated_sprite.play("attack")
		$Timer.start()

	if Input.is_action_just_pressed("attack_r") and not isSAttacking:
		isSAttacking = true
		attack_shape.disabled = false
		$AttackArea2/CollisionShape2D.disabled = false
		animated_sprite.play("attack-f")
		return

	if Input.is_action_just_pressed("attack_w") and not isSAttacking:
		isSAttacking = true
		attack_shape.disabled = false
		$AttackArea2/CollisionShape2D.disabled = false
		animated_sprite.play("attack-s")
		return

	if direction != 0 and not isSAttacking:
		velocity.x = move_toward(velocity.x, direction * speed, speed * acceleration)

		if animated_sprite.animation != "walk":
			animated_sprite.play("walk")
		animated_sprite.scale.x = abs(animated_sprite.scale.x) * (1 if direction > 0 else -1)
	else:
		velocity.x = move_toward(velocity.x, 0, walk_SPEED * deceleration)
		if not isSAttacking:
			# Only play the animation if it's not already playing
			if animated_sprite.animation != "idle":
				animated_sprite.play("idle")

	move_and_slide()

	attack_area.position.x = attack_offset.x * sign(animated_sprite.scale.x)
	attack_area.position.y = attack_offset.y


func _on_animated_sprite_2d_animation_finished() -> void:
	var anim = animated_sprite.animation
	if anim == "attack-s" or anim == "attack-f":
		attack_shape.disabled = true
		$AttackArea2/CollisionShape2D.disabled = true
		isSAttacking = false


func die() -> void:
	is_dead = true
	print("💀 Player died!")
	animated_sprite.play("death")
	await animated_sprite.animation_finished
	get_tree().reload_current_scene()


func _on_timer_timeout() -> void:
	attack_shape.disabled = true
	$AttackArea2/CollisionShape2D.disabled = true
	isSAttacking = false
