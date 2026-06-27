extends Camera2D

@export var look_ahead = 300
var shake_strenght: float = 0.0

func _process(delta: float) -> void:
	global_position.x = get_parent().global_position.x + look_ahead
	if shake_strenght > 0:
		offset = Vector2(
			randf_range(-shake_strenght, shake_strenght),
			randf_range(-shake_strenght, shake_strenght)
		)
		shake_strenght = lerp(shake_strenght, 0.0, delta * 10.0)
	else:
		offset = Vector2.ZERO

func shake(amount):
	shake_strenght = amount
