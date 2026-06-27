extends Area2D

@export var speed = 800
var is_fading = false

func _process(delta: float) -> void:
	position.x += speed * delta

func fade_out():
	if is_fading:
		return
	is_fading = true
	speed = 0
	for child in get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", true)
	var tween = create_tween()
	tween.tween_property(
		$Sprite2D,
		"modulate:a",
		0.0,
		0.5
	)
	await tween.finished
	queue_free()


func _on_tail_hit_area_entered(area: Area2D) -> void:
	if area.is_in_group("kBody"):
		fade_out()
	if area.is_in_group("rock"):
		fade_out()
	if area.is_in_group("rBody"):
		fade_out()
	if area.is_in_group("mBody"):
		fade_out()
	if area.is_in_group("gBody"):
		fade_out()
	
func _on_tail_hit_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		fade_out()
