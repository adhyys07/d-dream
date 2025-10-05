extends Area2D

@export var speed: float = 200.0
@export var damage: int = 5
var direction: Vector2

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
	queue_free()
