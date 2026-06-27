extends Area2D

@onready var sprite = $beamBody
@onready var ray = $RayCast2D
@onready var collision = $CollisionShape2D
@export var damage = 5

func _ready():
	sprite.centered = false 
	await get_tree().create_timer(6.0, false).timeout
	queue_free()

func _process(_delta):
	if ray.is_colliding():
		var hit_point = ray.get_collision_point()
		var distance = global_position.distance_to(hit_point)
		sprite.scale.x = distance / 200.0 
		collision.shape.size.x = distance
		collision.position.x = distance / 2.0

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(damage)
