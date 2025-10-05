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
