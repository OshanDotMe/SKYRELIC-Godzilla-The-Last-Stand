extends Area2D

@export var damage = 15

func _ready():
	body_entered.connect(_on_body_entered)
	await get_tree().create_timer(1.0, false).timeout
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"): 
		if body.has_method("take_damage"):
			body.take_damage(damage)
