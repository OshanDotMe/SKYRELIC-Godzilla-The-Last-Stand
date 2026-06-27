extends CharacterBody2D

@export var speed = 40.0
@export var bullet = preload("res://components/bullet.tscn")

var health = 40
var is_destroy = false
var time = 0.0
var start_y
var original_pos

func _ready() -> void:
	$sounds/MilitaryTank.stream.loop = true
	#$sounds/MilitaryTank.play()
	start_y = position.y
	original_pos = $Sprite2D.position
	
func _physics_process(delta):
	if is_destroy:
		velocity = Vector2.ZERO
		return
	time += delta
	velocity.x = -speed
	move_and_slide()
	$Sprite2D.position.x = original_pos.x + sin(time * 10.0) * 1.0
	$Sprite2D.position.y = original_pos.y + cos(time * 6.0) * 0.3

func take_damage(amount):
	if is_destroy:
		return
	health -= amount
	flash_hit()
	print("Tank HP:", health)
	if health <= 0:
		GameManager.add_score(10)
		die()

func flash_hit():
	if is_destroy:
		return
	$Sprite2D.modulate = Color(1, 0.3, 0.3)
	var original_pos = $Sprite2D.position
	for i in 4:
		$Sprite2D.position = original_pos + Vector2(
			randf_range(-2, 2),
			randf_range(-2, 2)
		)
		await get_tree().create_timer(0.03, false).timeout
	$Sprite2D.position = original_pos
	$Sprite2D.modulate = Color.WHITE

func die():
	if is_destroy:
		return
	is_destroy = true
	velocity = Vector2.ZERO
	$CollisionShape2D.set_deferred("disabled", true)
	$Area2D.monitoring = false
	$Area2D.monitorable = false
	$Sprite2D.visible = false
	$sounds/MilitaryTank.stop()
	$sounds/Explosion.play()
	$Sprite2D2.visible = true
	set_physics_process(false)
	await get_tree().create_timer(2.7, false).timeout
	var tween = create_tween()
	tween.tween_property(
		$Sprite2D2,
		"modulate:a",
		0.0,
		1.0
	)
	await  tween.finished
	queue_free()

func fire_loop():
	while !is_destroy:
		fire()
		await get_tree().create_timer(2.0, false).timeout

func fire():
	$sounds/TankFire.play()
	var bullets = bullet.instantiate()
	get_parent().add_child(bullets)
	bullets.global_position = $bulletSpawnPoint.global_position

func _on_area_2d_area_entered(area: Area2D) -> void:
	if is_destroy:
		return
	if area.is_in_group("tail"):
		take_damage(20)
		if is_destroy:
			GameManager.add_points(10)
	if area.is_in_group("body"):
		take_damage(40)
	if is_in_group("atomic_breath"):
		take_damage(40)


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	$sounds/MilitaryTank.play()
	fire_loop()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	$sounds/MilitaryTank.stop()
