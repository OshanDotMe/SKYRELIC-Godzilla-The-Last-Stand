extends Node2D

var target = null

func _ready() -> void:
	while target == null:
		await get_tree().process_frame
	$AnimatedSprite2D.play("flying")
	$sound/Mothra.play()
	$GPUParticles2D.emitting = false
	global_position = target.global_position + Vector2(-200, -400)
	var tween = create_tween()
	tween.tween_property(self, "global_position", target.global_position + Vector2(0, -150), 3.5)
	await tween.finished
	await get_tree().create_timer(2.0, false).timeout
	transform_to_energy()

func transform_to_energy():
	target.mothra_heal_effect() 
	$GPUParticles2D.emitting = true
	var tween = create_tween()
	tween.parallel().tween_property($AnimatedSprite2D, "modulate:a", 0.0, 1.5)
	#tween.parallel().tween_property(self, "scale", Vector2(0.2, 0.2), 1.0)
	await tween.finished
	queue_free()
