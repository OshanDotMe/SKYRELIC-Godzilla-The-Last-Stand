extends Area2D

var speed: float = 300.0
var is_destroyed = false

func _process(delta: float) -> void:
	if is_destroyed:
		return
	position.x -= speed * delta
	rotation_degrees += 500 * delta
	
  
func _on_rock_hit_area_entered(area: Area2D) -> void:
	if is_destroyed:
		return
	if area.is_in_group("body"):
		break_rock()
	if area.is_in_group("tail"):
		break_rock()

func break_rock():
	is_destroyed = true
	$Sprite2D.visible = false
	$Sprite2D2.visible = true
	var tween = create_tween()
	tween.tween_property(
		$Sprite2D2,
		"modulate:a",
		0.0,
		0.5
	)
	await  tween.finished
	queue_free()
