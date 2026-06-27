extends Control

var muted = false
@onready var title = $Label

func _ready() -> void:
	BackgroundMusic.set_menu_volume()
	start_title_animation()
	start_title_animation1()

func start_title_animation() -> void:
	var original_y = title.position.y
	var target_y = original_y - 10.0
	var tween = create_tween().set_loops()
	tween.tween_property(title, "position:y", target_y, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(title, "position:y", original_y, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func start_title_animation1() -> void:
	var original_y = $Label2.position.y
	var target_y = original_y - 10.0
	var tween = create_tween().set_loops()
	tween.tween_property($Label2, "position:y", target_y, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($Label2, "position:y", original_y, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_start_button_pressed() -> void:
	if GameManager.current_player_name == "":
		GameManager.reset_game_data()
		get_tree().change_scene_to_file("res://components/name_input.tscn")
	else:
		GameManager.reset_game_data()
		get_tree().change_scene_to_file("res://components/main.tscn")

func _on_shop_button_pressed() -> void:
	get_tree().change_scene_to_file("res://components/shop_menu.tscn")

func _on_how_to_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://components/hot_to_play.tscn")

func _on_mute_button_pressed() -> void:
	muted = !muted
	AudioServer.set_bus_mute(0, muted)

func _on_leaderboard_button_pressed() -> void:
	get_tree().change_scene_to_file("res://components/leader_board_menu.tscn")

func _on_start_button_mouse_entered() -> void:
	$hoverSoundPlayer.play()


func _on_shop_button_mouse_entered() -> void:
	$hoverSoundPlayer.play()


func _on_how_to_play_button_mouse_entered() -> void:
	$hoverSoundPlayer.play()


func _on_leaderboard_button_mouse_entered() -> void:
	$hoverSoundPlayer.play()


func _on_mute_button_mouse_entered() -> void:
	$hoverSoundPlayer.play()


func _on_quitbtn_pressed() -> void:
	get_tree().quit()


func _on_quitbtn_mouse_entered() -> void:
	$hoverSoundPlayer.play()
