extends Area2D

var enemies_in_fire = []
var active = true

func _ready() -> void:
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	damage_loop()
	await get_tree().create_timer(4, false).timeout
	active = false
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

func damage_loop():
	while active:
		for enemy in enemies_in_fire:
			if is_instance_valid(enemy) and enemy.has_method("take_damage"):
				enemy.take_damage(10)
		await get_tree().create_timer(0.5, false).timeout

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy") or area.get_parent().is_in_group("enemy"):
		var actual_enemy = area
		if area.get_parent().is_in_group("enemy"):
			actual_enemy = area.get_parent()
		if !enemies_in_fire.has(actual_enemy):
			enemies_in_fire.append(actual_enemy)


func _on_area_exited(area: Area2D) -> void:
	var actual_enemy = area
	if area.get_parent().is_in_group("enemy"):
		actual_enemy = area.get_parent()
	if enemies_in_fire.has(actual_enemy):
		enemies_in_fire.erase(actual_enemy)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") or body.get_parent().is_in_group("enemy"):
		if !enemies_in_fire.has(body):
			enemies_in_fire.append(body)

func _on_body_exited(body: Node2D) -> void:
	if enemies_in_fire.has(body):
		enemies_in_fire.erase(body)
