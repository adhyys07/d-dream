extends Area2D

func _on_area_2d_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		print("sup")
