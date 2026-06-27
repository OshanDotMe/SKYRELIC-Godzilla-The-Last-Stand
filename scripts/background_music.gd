extends Node

var audio_player : AudioStreamPlayer

func _ready() -> void:
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.stream = load("res://art/sounds/bg.wav")
	audio_player.play()

func set_menu_volume():
	audio_player.volume_db = -2.0

func set_gameplay_volume():
	audio_player.volume_db = -10.0
