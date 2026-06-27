extends CharacterBody2D

var health = 200
var is_dead = false
var is_throwing = false
var player_in_range = false
@export var throw_rock = preload("res://components/rock.tscn")
@onready var health_bar = $ProgressBar

const THROW_COOLDOWN = 4.0

func _ready() -> void:
	$body/AnimatedSprite2D.play("idle")
	start_attack_loop()

func _process(delta: float) -> void:
	health_bar.value = health
	
func take_damage(amount):
	health -= amount
	flash_hit()
	print("KingKong:", health)
	if health <= 0:
		GameManager.add_score(100)
		GameManager.add_points(50)
		die()

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

func spwan_rock():
	var rock = throw_rock.instantiate()
	get_parent().add_child(rock)
	rock.global_position = $Marker2D.global_position

func throw_attack():
	if is_throwing:
		return

	is_throwing = true
	var rock_spawned = false

	$body/AnimatedSprite2D.play("throw")
	

	while $body/AnimatedSprite2D.is_playing():

		if $body/AnimatedSprite2D.frame == 1 and !rock_spawned:
			spwan_rock()
			rock_spawned = true
			$sound/Throw.play()

		await get_tree().process_frame

	is_throwing = false

	if !is_dead:
		$body/AnimatedSprite2D.play("idle")

func start_attack_loop():
	while !is_dead:
		await get_tree().create_timer(THROW_COOLDOWN, false).timeout
		if !is_dead and player_in_range:
			throw_attack()

func fade_out():
	var tween = create_tween()
	tween.tween_property(
		$ProgressBar,
		"modulate:a",
		0.0,
		0.5
	)
	tween.tween_property(
		$body/AnimatedSprite2D,
		"modulate:a",
		0.0,
		1.0
	)
	await tween.finished
	queue_free()

func die():
	if is_dead:
		return
	is_dead = true
	$sound/KongDead.play()
	$blockWall.queue_free()
	$body/AnimatedSprite2D.play("dead")
	await $body/AnimatedSprite2D.animation_finished
	await get_tree().create_timer(2.0, false).timeout
	fade_out()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if player_in_range:
		if area.is_in_group("tail"):
			is_throwing = false
			$sound/KongHit.play()
			take_damage(20)

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		
		if !is_throwing:
			throw_attack()

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false


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
