extends CharacterBody2D

@export var speed = 60.0

var health = 20
var is_destroy = false
var time = 0.0
var start_y

func _ready() -> void:
	$sounds/HumveeSound.stream.loop = true
	#$sounds/HumveeSound.play()
	start_y = position.y

func _physics_process(delta):
	if is_destroy:
		velocity = Vector2.ZERO
		return
	time += delta
	velocity.x = -speed
	move_and_slide()
	position.y = start_y + sin(time * 8.0) * 1

func take_damage(amount):
	if is_destroy:
		return
	health -= amount
	print("Truck HP:", health)
	if health <= 0:
		GameManager.add_score(10)
		die()

func die():
	if is_destroy:
		return
	is_destroy = true
	velocity = Vector2.ZERO
	$CollisionShape2D.set_deferred("disabled", true)
	$Area2D.monitoring = false
	$Area2D.monitorable = false
	$Sprite2D.visible = false
	$sounds/HumveeSound.stop()
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


func _on_area_2d_area_entered(area: Area2D) -> void:
	if is_destroy:
		return
	if area.is_in_group("tail"):
		GameManager.add_points(10)
		take_damage(20)
	if area.is_in_group("body"):
		take_damage(20)

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	print("Truck Entered Screen")
	$sounds/HumveeSound.play()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	print("Truck Left Screen")
	$sounds/HumveeSound.stop()
