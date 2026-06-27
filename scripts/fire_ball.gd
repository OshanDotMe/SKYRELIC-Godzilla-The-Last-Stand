extends Area2D

@export var speed = 350.0
var target = null
var is_vanish = false

func _process(delta: float) -> void:
	if !is_instance_valid(target):
		queue_free()
		return
	var dir = (target.global_position - global_position).normalized()
	global_position += dir * speed * delta
	rotation = dir.angle()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if is_vanish:
		return
	if body.is_in_group("player"):
		is_vanish = true
		$Area2D/AnimatedSprite2D.play("vanish")
		await $Area2D/AnimatedSprite2D.animation_finished
		queue_free()
