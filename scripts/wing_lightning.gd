extends Area2D

@export var speed = 800
@export var damage = 20
var has_hit = false

func _ready():
	body_entered.connect(_on_body_entered)
	await get_tree().create_timer(1.0, false).timeout
	if !has_hit:
		queue_free()

func _process(delta):
	if !has_hit:
		global_position.x -= speed * delta

func fade_out():
	var tween = create_tween()
	tween.tween_property(
		$Sprite2D,
		"modulate:a",
		0.0,
		0.5
	)
	await tween.finished
	queue_free()

func _on_body_entered(body):
	if has_hit:
		return
	if body.is_in_group("player"):
		has_hit = true
		body.take_damage(damage)
		$CollisionShape2D.disabled = true
		fade_out()
