extends Area2D

func _on_Hitbox_area_entered(area):
	if area.is_in_group("player_attack"):
		take_damage(1)

'''func take_damage(amount: int):
    health -= amount
    if health <= 0:
        die()

func die():
    sprite.play("death")
    queue_free() # or fade out, drop loot, etc.
