extends Control

@onready var video_player = $ColorRect/VideoStreamPlayer
@onready var credits_label = $ColorRect/creditsLabel

func _ready() -> void:
	credits_label.visible = false
	credits_label.modulate.a = 0.0
	video_player.play()
	

func _on_video_stream_player_finished() -> void:
	video_player.queue_free()
	credits_label.visible = true
	var tween = create_tween()
	tween.tween_property(credits_label, "modulate:a", 0.5, 0.5).set_trans(Tween.TRANS_SINE)
	credits_label.visible_characters = 0
	tween.tween_property(credits_label, "visible_ratio", 1.0, 3.0)
	tween.tween_interval(3.0)
	tween.tween_property(credits_label, "modulate:a", 0.0, 1.0).set_trans(Tween.TRANS_SINE)
	await tween.finished
	get_tree().change_scene_to_file("res://components/main_menu.tscn")
