# Projectile.gd
extends Area2D

@export var speed: float = 450.0
@export var damage: int = 1
var velocity: Vector2 = Vector2.ZERO

# lifetime fallback
@export var max_lifetime: float = 5.0
var lifetime: float = 0.0

func _ready():
	lifetime = 0.0
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta):
	position += velocity * delta
	lifetime += delta
	if lifetime >= max_lifetime:
		queue_free()

func _on_body_entered(body):
	# Example: player has `take_damage(amount)` method
	if body.has_method("take_damage"):
		body.take_damage(damage)
	# optionally spawn hit effects here
	queue_free()

# helper to initialize from spawner
func launch(direction: Vector2, speed_override: float = -1.0):
	velocity = direction.normalized() * (speed_override if speed_override > 0 else speed)
	rotation = velocity.angle()
	lifetime = 0.0
