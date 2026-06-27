extends CharacterBody2D

@export var max_health = 400
@export var current_health = 400
@export var mouth_lightning_scene: PackedScene
@export var wing_attack_scene: PackedScene
@export var sky_lightning_scene: PackedScene
@onready var sprite = $body/AnimatedSprite2D
@onready var detection_area = $Area2D
@onready var mouth1 = $mouthPoint
@onready var mouth2 = $mouthPoint2
@onready var mouth3 = $mouthPoint3
@onready var wing_point = $wingPoint
@export var lightning_range = 500
@onready var health_bar = $ProgressBar
var player = null
var player_detected = false
var is_attacking = false
var is_dead = false
var is_on_screen = false

func _ready():
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)
	$sounds/GhidorahIdle.stream.loop = true
	if is_on_screen:
		set_idle_state()

func _process(delta: float) -> void:
	health_bar.value = current_health

func stop_all_sounds():
	$sounds/GhidorahAttack.stop()
	$sounds/GhidorahDamage.stop()
	$sounds/GhidorahIdle.stop()
	$sounds/GhidoraWing.stop()

func set_idle_state():
	if is_dead: return
	sprite.play("idle")
	if is_on_screen and not $sounds/GhidorahIdle.playing:
		stop_all_sounds()
		$sounds/GhidorahIdle.play()

func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body
		player_detected = true
		if !is_attacking:
			attack_loop()

func _on_body_exited(body):
	if body == player:
		player = null
		player_detected = false

func attack_loop():
	sky_loop()
	while player_detected and !is_dead:
		for i in range(1):
			if !player_detected or is_dead: break
			is_attacking = true 
			await mouth_attack()
			is_attacking = false
			await get_tree().create_timer(3.0, false).timeout
		if !is_dead:
			is_attacking = true
			await wing_attack()
			is_attacking = false
		set_idle_state()
		await get_tree().create_timer(randf_range(4.0, 6.0), false).timeout

func mouth_attack():
	stop_all_sounds()
	if is_on_screen:
		$sounds/GhidorahAttack.play()
	sprite.play("light_attack")
	await get_tree().create_timer(0.5, false).timeout
	spawn_mouth_lightning(mouth1)
	await get_tree().create_timer(0.2, false).timeout
	spawn_mouth_lightning(mouth2)
	await get_tree().create_timer(0.2, false).timeout
	spawn_mouth_lightning(mouth3)
	await get_tree().create_timer(1.0, false).timeout
	sprite.play("idle")

func spawn_mouth_lightning(point):
	var attack = mouth_lightning_scene.instantiate()
	get_parent().add_child(attack)
	attack.global_position = point.global_position

func wing_attack():
	stop_all_sounds()
	if is_on_screen:
		$sounds/GhidoraWing.play()
	sprite.play("wing_attack")
	sprite.frame = 0
	sprite.stop()
	await get_tree().create_timer(3.0, false).timeout
	sprite.play("wing_attack")
	await get_tree().create_timer(0.5, false).timeout
	var attack = wing_attack_scene.instantiate()
	get_parent().add_child(attack)
	attack.global_position = wing_point.global_position
	current_health = min(current_health + 50, max_health)
	await get_tree().create_timer(2.5, false).timeout

func start_sky_lightning():
	sky_loop()

func sky_loop():
	while player_detected and !is_dead:
		await get_tree().create_timer(randf_range(2.0, 4.0), false).timeout
		if !player_detected or is_dead: break
		if !is_attacking:
			spawn_sky_lightning()

func spawn_sky_lightning():
	var random_x = global_position.x - randf_range(
		100,
		lightning_range
	)
	await show_lightning_warning(random_x)
	var lightning = sky_lightning_scene.instantiate()
	get_parent().add_child(lightning)
	lightning.global_position = Vector2(
			random_x,
			global_position.y - 270
		)

func show_lightning_warning(pos_x):
	var warning = Polygon2D.new()
	warning.polygon = [
		Vector2(-40, 0), 
		Vector2(40, 0), 
		Vector2(40, 10), 
		Vector2(-40, 10)
	]
	warning.color = Color(1, 0.5, 0, 0.6)
	warning.global_position = Vector2(pos_x, global_position.y - (-110))
	get_parent().add_child(warning)
	await get_tree().create_timer(0.5, false).timeout
	warning.queue_free()

func take_damage(amount):
	current_health -= amount
	flash_hit()
	if is_on_screen:
		$sounds/GhidorahDamage.stop()
		$sounds/GhidorahDamage.play()
	print("Ghidorah:", current_health)
	if current_health <= 0:
		GameManager.add_score(100)
		GameManager.add_points(50)
		die()

func die():
	print("DIE START")
	if is_dead:
		return
	stop_all_sounds()
	$sounds/GhidorahDamage.play()
	is_dead = true
	player_detected = false
	is_attacking = false
	$blockWall.queue_free()
	sprite.play("dead")
	#print("WAITING DEAD ANIMATION")
	await sprite.animation_finished
	#print("DEAD ANIMATION FINISHED")
	fade_out()
	var player = get_tree().get_first_node_in_group("player")
	if is_instance_valid(player):
		player.lock_player_for_ending()
		player.play_cinematic_zoom()

func fade_out():
	var tween = create_tween()
	tween.tween_property(
		sprite,
		"modulate:a",
		0.0,
		2.0
	)
	await tween.finished
	queue_free()

func flash_hit():
	$body/AnimatedSprite2D.modulate = Color(1, 0.3, 0.3)
	var original_pos = $body.position
	
	for i in 4:
		$body.position = original_pos + Vector2(
			randf_range(-2, 2),
			randf_range(-2, 2)
		)
		await get_tree().create_timer(0.03, false).timeout
	$body.position = original_pos
	$body/AnimatedSprite2D.modulate = Color(1, 1, 1)

func _on_area_2d_2_area_entered(area: Area2D) -> void:
	if player_detected:
		if area.is_in_group("tail"):
			take_damage(20)

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	is_on_screen = true
	if is_dead:
		return
	if !is_attacking:
		set_idle_state()
	else:
		if sprite.animation == "light_attack" and !$sounds/GhidorahAttack.playing:
			$sounds/GhidorahAttack.play()
		elif sprite.animation == "wing_attack" and !$sounds/GhidoraWing.playing:
			$sounds/GhidoraWing.play()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	is_on_screen = false
	stop_all_sounds()

func _on_spawn_stop_trigger_body_entered(body: Node2D) -> void:
	if body.name == "player" or body.is_in_group("player"):
		if body.has_node("enemySpawner"):
			var spawner = body.get_node("enemySpawner")
			spawner.get_node("Timer").stop()
			print("enemy stopeddddddd!!!!!")
