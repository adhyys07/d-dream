extends CharacterBody2D

# --- EXPORTS (Variables you can edit in the Inspector) ---
@export var walk_SPEED = 150.0
@export var run_SPEED = 300.0
@export_range(0, 1) var acceleration = 0.1
@export_range(0, 1) var deceleration = 0.1
@export var jump_force = -400.0
@export_range(0, 1) var decelerate_on_jump_release = 0.5

# --- STATE VARIABLES (Track what the character is doing) ---
var isSAttacking: bool = false
var is_dead: bool = false

# --- NODE REFERENCES (Links to other nodes in the scene) ---
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D

# --- OTHER VARIABLES ---
var attack_offset: Vector2

# --- GODOT'S BUILT-IN FUNCTIONS ---

func _ready() -> void:
	# Store the initial position of the attack area
	attack_offset = attack_area.position
	# Make sure hitboxes are off when the game starts
	attack_shape.disabled = true
	$AttackArea2/CollisionShape2D.disabled = true


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# --- DEBUGGING: Check if the raw input is detected ---
	if Input.is_action_just_pressed("attack_r"):
		print("DEBUG: 'attack_r' (Ctrl key) was pressed THIS FRAME.")

	# --- Gravity ---
	if not is_on_floor():
		velocity += get_gravity() * delta

	# --- Handle Player Actions ---
	# We split the logic into smaller functions to keep it clean
	handle_attacks()
	handle_movement()

	# --- Apply Physics and Move the Character ---
	move_and_slide()

	# --- Update Attack Area Position ---
	# This ensures the hitbox flips with the character's direction
	attack_area.position.x = attack_offset.x * sign(animated_sprite.scale.x)
	attack_area.position.y = attack_offset.y


# --- LOGIC HANDLER FUNCTIONS ---

func handle_attacks():
	# If we are already in an attack, don't start a new one.
	if isSAttacking:
		return

	# Check for different attack inputs, but only if on the floor.
	if Input.is_action_just_pressed("attack") and is_on_floor():
		start_attack("attack")
		$Timer.start() # This timer is only for the hitbox duration

	if Input.is_action_just_pressed("attack_r") and is_on_floor():
		print("DEBUG: Condition met for 'attack-f'. Calling start_attack.")
		start_attack("attack-f")

	if Input.is_action_just_pressed("attack_w") and is_on_floor():
		start_attack("attack-s")

func handle_movement():
	# If attacking, the character just slows down to a stop. No other movement is allowed.
	if isSAttacking:
		velocity.x = move_toward(velocity.x, 0, walk_SPEED * deceleration)
		return

	# --- Jump ---
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
	# Allows for variable jump height
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= decelerate_on_jump_release

	# --- Horizontal Movement ---
	var speed = run_SPEED if Input.is_action_pressed("dash") else walk_SPEED
	var direction = Input.get_axis("left", "right")

	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * speed, speed * acceleration)
		play_animation("walk")
		# Flip the sprite based on direction
		animated_sprite.scale.x = abs(animated_sprite.scale.x) * (1 if direction > 0 else -1)
	else:
		# If no direction is pressed, slow down and play idle animation.
		velocity.x = move_toward(velocity.x, 0, walk_SPEED * deceleration)
		play_animation("idle")

# --- HELPER FUNCTIONS (For repeated tasks) ---

func play_animation(anim_name: String):
	# This helper function prevents animations from restarting on every frame.
	if animated_sprite.animation != anim_name:
		animated_sprite.play(anim_name)

func start_attack(attack_anim: String):
	# This function centralizes the logic for starting any attack.
	isSAttacking = true
	attack_shape.disabled = false
	$AttackArea2/CollisionShape2D.disabled = false
	play_animation(attack_anim)


# --- SIGNAL CONNECTIONS (Functions called by signals from other nodes) ---

# This is now the ONLY place that resets the attacking state for ALL attacks.
# It fires when any animation finishes.
func _on_animated_sprite_2d_animation_finished() -> void:
	var anim = animated_sprite.animation
	
	# Check if the animation that just finished was one of the attacks.
	if anim == "attack" or anim == "attack-s" or anim == "attack-f":
		isSAttacking = false
		# The timer handles the hitbox for the main "attack",
		# but for the others, we disable them here as soon as the animation is done.
		attack_shape.disabled = true
		$AttackArea2/CollisionShape2D.disabled = true

# This timer's ONLY job is to disable the hitboxes. It no longer touches player state.
func _on_timer_timeout() -> void:
	attack_shape.disabled = true
	$AttackArea2/CollisionShape2D.disabled = true

# --- DEATH FUNCTION ---
func die() -> void:
	if is_dead: return
	is_dead = true
	print("💀 Player died!")
	play_animation("death")
	await animated_sprite.animation_finished
	get_tree().reload_current_scene()
