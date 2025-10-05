extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _level_complete():
	get_tree().change_scene("res://scenes/ui/Shop.tscn")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_tree().get_nodes_in_group("enemy").size() == 0:
		_level_complete()


func _on_timer_timeout() -> void:
	pass
	
	
	await get_tree().create_timer(10.0).timeout
	$CharacterBody2D.queue_free() # Replace with function body.
	await get_tree().create_timer(15.0).timeout 
	$CharacterBody2D2.queue_free()
	await get_tree().create_timer(20.75).timeout 
	$CharacterBody2D3.queue_free()
	await get_tree().create_timer(25.50).timeout 
	$CharacterBody2D4.queue_free()
	await get_tree().create_timer(30.25).timeout 
	get_tree().change_scene("res://scenes/ui/Shop.tscn")
