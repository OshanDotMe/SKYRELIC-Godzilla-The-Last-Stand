extends Area2D

var player_inside = false
var active = true

func _ready() -> void:
	$sounds/Fire.stream.loop = true
	$Area2D/AnimatedSprite2D.play("idle")
	$Area2D/AnimatedSprite2D2.play("idle")
	$Area2D/AnimatedSprite2D3.play("idle")
	$Area2D/AnimatedSprite2D4.play("idle")
	$Area2D/AnimatedSprite2D5.play("idle")
	damage_loop()

func damage_loop():
	while active:
		if player_inside:
			var player = get_tree().get_first_node_in_group("player")
			
			if player and player.has_method("take_damage"):
				player.take_damage(40)
		await get_tree().create_timer(0.5, false).timeout
		

func fade_out():
	active = false
	var tween = create_tween()
	tween.tween_property(
		$Area2D/AnimatedSprite2D,
		"modulate:a",
		0.0,
		1.0
	)
	tween.tween_property(
		$Area2D/AnimatedSprite2D2,
		"modulate:a",
		0.0,
		0.8
	)
	tween.tween_property(
		$Area2D/AnimatedSprite2D3,
		"modulate:a",
		0.0,
		0.6
	)
	tween.tween_property(
		$Area2D/AnimatedSprite2D4,
		"modulate:a",
		0.0,
		0.4
	)
	tween.tween_property(
		$Area2D/AnimatedSprite2D5,
		"modulate:a",
		0.0,
		0.2
	)
	await tween.finished
	$sounds/Fire.stop()
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	$sounds/Fire.play()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	$sounds/Fire.stop()
