extends Node2D

var Enemy = preload("res://scenes/characters/enemy1.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_timer_timeout() -> void:
	var enemy = Enemy.instantiate()
	var enemy2 = Enemy.instantiate()
	add_child(enemy)
	enemy.position = $Spawn.position
	add_child(enemy2)
	enemy.position = $Spawn2.position
