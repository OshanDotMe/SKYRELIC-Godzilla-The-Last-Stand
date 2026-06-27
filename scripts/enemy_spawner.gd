extends Node2D

@export var humvee_scene = preload("res://components/military_humvee.tscn")
@export var tank_scene = preload("res://components/military_tank.tscn")
@onready var timer = $Timer

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout() -> void:
	var enemy_instance
	if randf() > 0.4:
		enemy_instance = humvee_scene.instantiate()
	else:
		enemy_instance = tank_scene.instantiate()
	var spwan_pos = Vector2(global_position.x + 1000, 496)
	enemy_instance.global_position = spwan_pos
	get_tree().current_scene.add_child(enemy_instance)
