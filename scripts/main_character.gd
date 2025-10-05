extends CharacterBody2D

@export var walk_SPEED = 150.0
@export var run_SPEED = 300
@export_range(0, 1) var acceleration = 0.1
@export_range(0, 1) var deceleration = 0.1
@export var jump_force = -400
@export_range(0, 1) var decelerate_on_jump_release = 0.5 
const JUMP_VELOCITY = -400.0

func _physics_process(delta: float) -> void:
		velocity += get_gravity() * delta
		
# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_force 

		if Input.is_action_just_released("jump") and velocity.y < 0:
			velocity.y *= decelerate_on_jump_release

		var speed
		if  Input.is_action_pressed('dash'):
			speed = run_SPEED
		else:
			speed = walk_SPEED

		var direction := Input.get_axis("left", "right")
		if direction:
					velocity.x = move_toward(velocity.x, direction * speed, speed * acceleration) 
		else:
			velocity.x = move_toward(velocity.x, 0, walk_SPEED * deceleration)

		move_and_slide()
