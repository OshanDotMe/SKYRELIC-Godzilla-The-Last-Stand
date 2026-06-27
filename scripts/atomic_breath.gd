extends Area2D

func _ready() -> void:
	await get_tree().create_timer(4, false).timeout
	fade_out()

func fade_out():
	var tween = create_tween()
	tween.tween_property(
		$Sprite2D,
		"modulate:a",
		0.0,
		1.5
	)
	await tween.finished
	queue_free()
