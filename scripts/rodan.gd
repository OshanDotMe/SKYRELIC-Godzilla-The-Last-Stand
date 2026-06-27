extends CharacterBody2D

enum State{
	PATROL,
	ATTACKING,
	RESTING
}
var current_state = State.PATROL
var player_in_range = false
var moving_right = true
var is_busy = false
var health = 250
var is_dead = false
var sound_loop_active = true

@export var patrol_speed = 100.0
@export var left_point: Marker2D
@export var middle_point: Marker2D
@export var floor_point: Marker2D
@export var fireball_scene = preload("res://components/fire_ball.tscn")
@export var flame_area: Node2D
@onready var health_bar = $ProgressBar

func _ready() -> void:
	$body/AnimatedSprite2D.play("flying")
	global_position = left_point.global_position

func rodan_fly_sound_loop():
	sound_loop_active = true
	while sound_loop_active:
		if is_dead:
			return
		if current_state == State.RESTING:
			await get_tree().create_timer(0.1, false).timeout
			continue
		if is_dead or !sound_loop_active:
			return
		if !$sounds/RodanFly.playing:
			$sounds/RodanFly.play()
		await get_tree().create_timer(
			$sounds/RodanFly.stream.get_length(), false
		).timeout
		await get_tree().create_timer(0.2, false).timeout

func _process(delta: float) -> void:
	match current_state:
		State.PATROL:
			patrol(delta)
		State.ATTACKING:
			pass
		State.RESTING:
			pass
	health_bar.value = health

func patrol(delta):
	if is_dead:
		return
	if moving_right:
		global_position.x += patrol_speed * delta
		$body/AnimatedSprite2D.flip_h = false
		if global_position.x >= middle_point.global_position.x:
			moving_right = false
	else:
		global_position.x -= patrol_speed * delta
		$body/AnimatedSprite2D.flip_h = true
		if global_position.x <= left_point.global_position.x:
			moving_right = true
	if player_in_range and !is_busy:
		start_attack_cycle()

func start_attack_cycle():
	if is_dead:
		return
	is_busy = true
	current_state = State.ATTACKING
	await move_to_point(left_point.global_position)
	if is_dead:
		return
	await attack_phase()
	if is_dead:
		return
	await move_to_point(middle_point.global_position)
	if is_dead:
		return
	await move_to_point(floor_point.global_position)
	if is_dead:
		return
	await rest_phase()
	if is_dead:
		return
	await move_to_point(middle_point.global_position)
	current_state = State.PATROL
	is_busy = false

func move_to_point(target):
	while global_position.distance_to(target) > 10:
		if target.x > global_position.x:
			$body/AnimatedSprite2D.flip_h = false
		else:
			$body/AnimatedSprite2D.flip_h = true
		global_position = global_position.move_toward(
			target,
			150 * get_process_delta_time()
		)
		await get_tree().process_frame

func attack_phase():
	var attacks = 5
	for i in range(attacks):
		if not is_inside_tree():
			return
		var spwaned = false
		await get_tree().create_timer(0.2, false).timeout
		if not is_inside_tree():
			return
		$body/AnimatedSprite2D.play("attack")
		while is_inside_tree() and $body/AnimatedSprite2D.is_playing():
			if $body/AnimatedSprite2D.frame == 1 and !spwaned:
				spawn_fireball()
				$sounds/RodanFire.play()
				spwaned = true
			await Engine.get_main_loop().process_frame
		if not is_inside_tree():
			return
	if is_inside_tree():
		$body/AnimatedSprite2D.play("flying")
		await get_tree().create_timer(1.0, false).timeout

func spawn_fireball():
	var fireball = fireball_scene.instantiate()
	get_parent().add_child(fireball)
	fireball.global_position = $fireSpwanPoint.global_position
	fireball.target = get_tree().get_first_node_in_group("player")

func rest_phase():
	if is_dead:
		return
	$body/AnimatedSprite2D.flip_h = true
	current_state = State.RESTING
	$sounds/RodanFly.stop()
	$sounds/RodanIdle.play()
	$body/AnimatedSprite2D.play("idle")
	await get_tree().create_timer(6.3, false).timeout
	if is_dead:
		return 
	$sounds/RodanIdle.stop()
	$sounds/RodanFly.play()
	$body/AnimatedSprite2D.play("flying")
	
func take_damage(amount):
	if is_dead:
		return
	health -= amount
	flash_hit()
	print("Rodan:", health)
	if health <= 0:
		GameManager.add_score(100)
		GameManager.add_points(50)
		die()

func flash_hit():
	if is_dead:
		return
	$body/AnimatedSprite2D.modulate = Color(1, 0.3, 0.3)
	var original_pos = $body.position
	for i in 4:
		$body.position = original_pos + Vector2(
			randf_range(-2, 2),
			randf_range(-2, 2)
		)
		await get_tree().create_timer(0.03, false).timeout
	$body.position = original_pos
	$body/AnimatedSprite2D.modulate = Color.WHITE

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
	sound_loop_active = false
	is_dead = true
	is_busy = true
	player_in_range = false
	current_state = State.RESTING
	$sounds/RodanFly.stop()
	$sounds/RodanIdle.stop()
	$sounds/RodanFire.stop()
	stop_all_behavior()
	await get_tree().process_frame
	velocity = Vector2.ZERO
	if flame_area:
		flame_area.fade_out()
	$body/AnimatedSprite2D.play("dead")
	await $body/AnimatedSprite2D.animation_finished
	await get_tree().create_timer(1.5, false).timeout
	fade_out()

func stop_all_behavior():
	current_state = State.RESTING
	is_busy = true
	player_in_range = false

	$sounds/RodanFly.stop()
	$sounds/RodanIdle.stop()
	$sounds/RodanFire.stop()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("tail"):
		$sounds/RodanHit.play()
		take_damage(20)


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	rodan_fly_sound_loop.call_deferred()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	$sounds/RodanFly.stop()

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
