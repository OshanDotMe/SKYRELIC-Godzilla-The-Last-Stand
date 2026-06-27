extends Area2D

@export var speed = 500

var target = null
var has_hit = false

func _ready():
	monitoring = true

func _process(delta: float) -> void:
	if target == null:
		queue_free()
		return
	var dir = (target.global_position - global_position).normalized()
	position += dir * speed * delta
	rotation = dir.angle()

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if has_hit:
		return
	has_hit = true
	body.take_damage(2)
	queue_free()
