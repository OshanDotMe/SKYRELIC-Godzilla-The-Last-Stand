extends Area2D

@export var speed = 250.0

func _process(delta: float) -> void:
	position.x -= speed * delta
