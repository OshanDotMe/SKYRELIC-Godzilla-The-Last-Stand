extends Area2D

@export var damage = 15

func _ready():
	var audio = get_tree().current_scene.get_node("lightningAudio")
	audio.play()
	body_entered.connect(_on_body_entered)
	modulate.a = 0
	var tween = create_tween()
	tween.tween_property(
		self,
		"modulate:a",
		1.0,
		0.1
	)
	await tween.finished
	await get_tree().create_timer(0.25, false).timeout
	queue_free()


func _on_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(damage)
