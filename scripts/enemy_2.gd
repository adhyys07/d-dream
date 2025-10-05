extends Node2D

@export var projectile_scene: PackedScene
@export var shoot_interval: float = 2.0
@export var projectile_speed: float = 400.0
@export var detection_range: float = 600.0

var player: Node2D

func _ready():
	player = get_tree().get_first_node_in_group("player")
	$Timer.wait_time = shoot_interval
	$Timer.start()

func _process(_delta):
	if not player:
		return
	
	# Flip blob sprite depending on player's position
	if player.global_position.x < global_position.x:
		$Sprite2D.flip_h = true
	else:
		$Sprite2D.flip_h = false

func _on_Timer_timeout():
	if not player:
		return

	var distance = global_position.distance_to(player.global_position)
	if distance > detection_range:
		return

	shoot_projectile()

func shoot_projectile():
	if not projectile_scene:
		return
	
	var projectile = projectile_scene.instantiate()
	get_parent().add_child(projectile)

	var direction = (player.global_position - global_position).normalized()
	projectile.global_position = $Marker2D.global_position
	projectile.rotation = direction.angle()
	
	# If using RigidBody2D
	if projectile.has_method("apply_central_impulse"):
		projectile.apply_central_impulse(direction * projectile_speed)
	# If using Area2D
	elif projectile.has_variable("velocity"):
		projectile.velocity = direction * projectile_speed
