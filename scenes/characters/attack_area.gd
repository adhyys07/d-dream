extends Area2D

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("enemy"):
		body.queue_free()
