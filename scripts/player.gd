extends CharacterBody2D

@export var speed: float = 40.0
@onready var player_sprite: AnimatedSprite2D = $body/AnimatedSprite2D
@export var breath_scene = preload("res://components/atomic_breath.tscn")
@export var breath_scene_floor = preload("res://components/atomic_breath_floor.tscn")
@export var nor_attack = preload("res://components/normal_power.tscn")
@onready var rodan = $"../rodanFull/rodan"
@export var max_health = 200
@export var mothra_scene : PackedScene
@onready var aura_area = $radiationAura
@onready var atomic_cooldown = GameManager.atomic_cooldown_time
var enemies_in_aura = []

var health = 200
var is_attacking = false
var is_charging = false
var is_locked = false
var is_moving = false
var can_tail_attack = true
var mothra_used = false
var is_dead = false
var atomic_charge: float = 100.0
var can_refill_bar: bool = true
const MAX_ATOMIC: float = 100.0
const BEAM_TIME = 5.4
const TAIL_COOLDOWN = 1.0

func _ready() -> void:
	BackgroundMusic.set_gameplay_volume()
	max_health = GameManager.max_health
	health = max_health
	atomic_cooldown = GameManager.atomic_cooldown_time
	add_to_group("player")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		normal_attack()
	if event.is_action_pressed("attomic"):
		start_atomic_breath()

func _process(delta):
	if Input.is_action_just_pressed("mothra_heal"):
		use_mothra()
	if can_refill_bar and atomic_charge < MAX_ATOMIC:
		atomic_charge += (MAX_ATOMIC / GameManager.atomic_cooldown_time) * delta

func start_aura():
	aura_area.body_entered.connect(_on_radiation_aura_body_entered)
	aura_area.body_exited.connect(_on_radiation_aura_body_exited)
	aura_damage_loop()

func aura_damage_loop():
	while !is_dead:
		if GameManager.radiation_aura_damage > 0:
			for enemy in enemies_in_aura:
				if is_instance_valid(enemy) and enemy.has_method("take_damage"):
					enemy.take_damage(GameManager.radiation_aura_damage)
		await get_tree().create_timer(1.0, false).timeout

func _on_radiation_aura_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		if !enemies_in_aura.has(body):
			enemies_in_aura.append(body)

func _on_radiation_aura_body_exited(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		enemies_in_aura.erase(body)

func use_mothra():
	if mothra_used:
		return
	mothra_used = true
	is_locked = true
	if $sound/GodzillaWalking.playing:
		$sound/GodzillaWalking.stop()
		$body/AnimatedSprite2D.stop()
	var mothra = mothra_scene.instantiate()
	get_parent().add_child(mothra)
	mothra.global_position = global_position + Vector2(0, -800)
	mothra.target = self

func mothra_heal_effect():
	health = max_health
	var hud = get_tree().get_first_node_in_group("gameHUD")
	if hud:
		hud.health_bar.value = health
	print("Mothra heal complete! Godzilla Current Health: ", health)
	modulate = Color(0.4, 1.0, 1.0)
	await get_tree().create_timer(0.5, false).timeout
	modulate = Color.WHITE
	is_locked = false

func _physics_process(delta: float) -> void:
	if is_locked:
		velocity.x = 0
		move_and_slide()
		if is_charging or is_attacking:
			if $sound/GodzillaIdle.playing:
				$sound/GodzillaIdle.stop()
		return
	if velocity.x != 0:
		if !$sound/GodzillaWalking.playing:
			$sound/GodzillaWalking.play()
		if $sound/GodzillaIdle.playing:
			$sound/GodzillaIdle.stop()
	else:
		if $sound/GodzillaWalking.playing:
			$sound/GodzillaWalking.stop()
	var direction: float = Input.get_axis("ui_left","ui_right")
	if direction != 0:
		$Camera2D.shake(0.5)
		velocity.x = direction * speed
		is_moving = true
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		is_moving = false
	move_and_slide()
	if !is_attacking and !is_charging:
		if velocity.x == 0:
			player_sprite.play("idel")
			if !$sound/GodzillaIdle.playing:
				$sound/GodzillaIdle.play()
		else:
			player_sprite.play("walking")
	else:
		if $sound/GodzillaIdle.playing:
			$sound/GodzillaIdle.stop()
	
	if velocity.x > 0:
		player_sprite.flip_h = false
	elif  velocity.x < 0:
		player_sprite.flip_h = true
		
func normal_attack():
	if player_sprite.flip_h:
		return
	if is_attacking:
		return
	if !can_tail_attack:
		return
	can_tail_attack = false
	is_attacking = true
	player_sprite.play("attack")
	$sound/TailSwip.play()
	await get_tree().create_timer(0.2, false).timeout
	spawn_wave()
	await player_sprite.animation_finished
	is_attacking = false
	start_tail_cooldown()
	
func spawn_wave():
	var wave = nor_attack.instantiate()
	get_parent().add_child(wave)
	wave.global_position = $tailAttackSpawnpoint.global_position

func start_atomic_breath():
	if player_sprite.flip_h:
		return
	if atomic_charge < MAX_ATOMIC or is_attacking:
		return
	atomic_charge = 0.0
	can_refill_bar = false
	is_attacking = true
	is_charging = true
	is_locked = true
	player_sprite.play("attomic_breath")
	if $sound/GodzillaWalking.playing:
		$sound/GodzillaWalking.stop()
	$sound/GodzillaAtomicBreath.play()
	await get_tree().create_timer(5.0, false).timeout
	start_beam()

func start_beam():
	var beam = breath_scene.instantiate()
	var beam_floor = breath_scene_floor.instantiate()
	beam.position = Vector2.ZERO
	beam_floor.position = Vector2.ZERO
	var mouse_y = get_global_mouse_position().y
	var mouth_y = $breathSpawnPointR.global_position.y
	if player_sprite.flip_h:
		is_charging = false
		is_attacking = false
	else:
		if mouse_y > mouth_y:
			$breathSpawnPointR.add_child(beam_floor)
		else:
			$breathSpawnPointR.add_child(beam)
			beam.rotation_degrees = 0
	await get_tree().create_timer(BEAM_TIME, false).timeout
	stop_beam(beam)
	stop_beam(beam_floor)

func stop_beam(beam):
	is_charging = false
	is_attacking = false
	is_locked = false
	player_sprite.play("idel")
	can_refill_bar = true
	if !$sound/GodzillaIdle.playing and velocity.x == 0:
		$sound/GodzillaIdle.play()

func start_tail_cooldown():
	await get_tree().create_timer(TAIL_COOLDOWN, false).timeout
	can_tail_attack = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("TOUCHED:", body.name)
	if body.is_in_group("enemy"):
		$sound/GodzillaHit.play()
		take_damage(1)
	
func take_damage(amount: int):
	health -= amount
	var hud = get_tree().get_first_node_in_group("gameHUD")
	if hud:
		hud.health_bar.value = health
	print("Player HP:", health)
	if health <= 0:
		die()

func die():
	if is_dead:
		return
	is_dead = true
	is_locked = true
	velocity = Vector2.ZERO
	player_sprite.play("idel")
	if $sound/GodzillaWalking.playing:
		$sound/GodzillaWalking.stop()
	GameManager.upload_score_to_global(GameManager.current_player_name, GameManager.score)
	var hud = get_tree().get_first_node_in_group("gameHUD")
	if hud:
		hud.show_game_over()

func _on_area_2d_area_entered(area: Area2D) -> void:
	print("Hit:", area.name)
	if area.is_in_group("bullet"):
		$sound/GodzillaHit.play()
		take_damage(1)
		area.queue_free()
	if area.is_in_group("rock"):
		$sound/Hit.play()
		$sound/GodzillaHit.play()
		take_damage(4)
	if area.is_in_group("fire"):
		$sound/Hit.play()
		$sound/GodzillaHit.play()
		take_damage(3)
	if area.is_in_group("missile"):
		$sound/Hit.play()
		$sound/GodzillaHit.play()
		take_damage(6)

func lock_player_for_ending():
	is_locked = true
	if $sound/GodzillaWalking.playing:
		$sound/GodzillaWalking.stop()
	await get_tree().create_timer(2.0).timeout
	$body/AnimatedSprite2D.play("roar")
	
func play_cinematic_zoom():
	var camera = $Camera2D 
	camera.offset = Vector2.ZERO
	var tween = create_tween().set_parallel(true)
	tween.tween_property(camera, "zoom", Vector2(1.6, 1.6), 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(2.0).timeout
	play_victory_roar()

func play_victory_roar():
	if has_node("roarPlayer"):
		$roarPlayer.play()
	var camera = $Camera2D
	var elapsed_time = 0.0
	var roar_duration = 4.3
	while elapsed_time < roar_duration:
		var shake_offset_x = randf_range(-3.0, 3.0)
		var shake_offset_y = randf_range(-3.0, 3.0)
		camera.offset = Vector2(shake_offset_x, shake_offset_y)
		await get_tree().create_timer(0.02).timeout
		elapsed_time += 0.02
	var reset_tween = create_tween()
	reset_tween.tween_property(camera, "offset", Vector2.ZERO, 0.2).set_trans(Tween.TRANS_SINE)
	if has_node("roarPlayer"):
		$roarPlayer.stop()
	show_victory_screen()

func show_victory_screen():
	var victory_ui = get_tree().current_scene.get_node("victoryUI")
	if victory_ui:
		victory_ui.visible = true

func _on_rodan_detection_area_body_entered(body):
	if body.is_in_group("player") and is_instance_valid(rodan):
		rodan.player_in_range = true

func _on_rodan_detection_area_body_exited(body):
	if body.is_in_group("player") and is_instance_valid(rodan):
		rodan.player_in_range = false
