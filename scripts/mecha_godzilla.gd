extends CharacterBody2D

@export var max_health = 300
@export var current_health = 300
@export var missile_scene: PackedScene
@export var proton_beam_scene: PackedScene
@onready var sprite = $body/AnimatedSprite2D
@onready var detection_area = $detectionArea
@onready var attack_point = $attackPoint
@onready var beam_point = $protonBeam
@onready var health_bar = $ProgressBar
var player = null
var player_detected = false
var is_attacking = false
var beam_active = false
var is_dead = false
var current_beam = null
var cancel_attack = false

func _ready() -> void:
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)
	$sounds/MechaIdle.stream.loop = true
	sprite.play("idle")

func _process(delta: float) -> void:
	health_bar.value = current_health

func stop_all_sounds():
	$sounds/MechaIdle.stop()
	$sounds/MechaMissile.stop()
	$sounds/MechaProtonBeam.stop()

func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body
		player_detected = true
		if !is_attacking:
			attack_loop()
			
func _on_body_exited(body):
	if body.is_in_group("player"):
		if body == player:
			player = null
			player_detected = false

func attack_loop():
	is_attacking = true
	while player_detected and !is_dead:
		await missile_attack()
		if is_dead or !player_detected:
			break
		await proton_beam_attack()
		if is_dead or !player_detected:
			break
		await get_tree().create_timer(
			randf_range(5.0, 6.0), false
		).timeout
	is_attacking = false
	if !is_dead:
		$sounds/MechaIdle.play()
		sprite.play("idle")

func missile_attack():
	if is_dead:
		return
	stop_all_sounds()
	$sounds/MechaMissile.play()
	sprite.play("missle_attack")
	await get_tree().create_timer(0.5, false).timeout
	if is_dead or !player_detected:
		return
	for i in range(5):
		if is_dead or !player_detected:
			return
		if cancel_attack:
			return
		spawn_missile()
		await get_tree().create_timer(0.15, false).timeout
	await get_tree().create_timer(1.5, false).timeout
	if !player_detected or is_dead:
		return

func spawn_missile():
	if player == null or is_dead:
		return
	var missile = missile_scene.instantiate()
	get_parent().add_child(missile)
	missile.global_position = attack_point.global_position
	missile.target = player
	
func proton_beam_attack():
	if is_dead:
		return
	stop_all_sounds()
	$sounds/MechaProtonBeam.play()
	sprite.play("proton_beam")
	await get_tree().create_timer(4.0, false).timeout
	if cancel_attack:
		return
	if is_dead or !player_detected:
		return
	spawn_proton_beam()
	heal_during_beam()
	await get_tree().create_timer(3.8, false).timeout
	if current_beam:
		current_beam.queue_free()
		current_beam = null
	if !is_dead:
		stop_all_sounds()
		$sounds/MechaIdle.play()
		sprite.play("idle")

func spawn_proton_beam():
	if player == null or is_dead:
		return
	current_beam = proton_beam_scene.instantiate()
	get_parent().add_child(current_beam)
	current_beam.global_position = beam_point.global_position
	
func heal_during_beam():
	current_health += 50
	if current_health > max_health:
		current_health = max_health
	
func take_damage(amount):
	current_health -= amount
	flash_hit()
	print("Mechagodzilla:", current_health)
	if current_health <= 0:
		GameManager.add_score(100)
		GameManager.add_points(50)
		die()

func die():
	print("DIE START")
	if is_dead:
		return
	stop_all_sounds()
	$sounds/MechaDead.play()
	is_dead = true
	player_detected = false
	beam_active = false
	is_attacking = false
	$blockWall.queue_free()
	if current_beam:
		current_beam.queue_free()
		current_beam = null
	sprite.play("dead")
	print("WAITING DEAD ANIMATION")
	await sprite.animation_finished
	print("DEAD ANIMATION FINISHED")
	fade_out()

func fade_out():
	var tween = create_tween()
	tween.tween_property(
		sprite,
		"modulate:a",
		0.0,
		3.5
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

func _on_area_2d_area_entered(area: Area2D) -> void:
	if player_detected:
		if area.is_in_group("tail"):
			take_damage(20)

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body == player:
			player = null
			player_detected = false
			if current_beam:
				current_beam.queue_free()
				current_beam = null
			stop_all_sounds()
			$sounds/MechaIdle.stream.loop = true
			$sounds/MechaIdle.play()
			sprite.play("idle")

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	if !is_dead and !$sounds/MechaIdle.playing:
		$sounds/MechaIdle.play()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	stop_all_sounds()

func _on_spawn_stop_trigger_body_entered(body: Node2D) -> void:
	if body.name == "player" or body.is_in_group("player"):
		if body.has_node("enemySpawner"):
			var spawner = body.get_node("enemySpawner")
			spawner.get_node("Timer").stop()
			print("enemy stopeddddddd!!!!!")

func _on_spawn_stop_trigger_body_exited(body: Node2D) -> void:
	if body.name == "player" or body.is_in_group("player"):
		if body.has_node("enemySpawner"):
			body.get_node("enemySpawner/Timer").start()
			print("enemy startttt!!!!!")
