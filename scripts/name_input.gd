extends Control

@onready var name_edit: LineEdit = $ColorRect/LineEdit

func _on_continue_btn_pressed() -> void:
	var entered_name = name_edit.text.strip_edges()
	if entered_name == "":
		print("Please enter a valid name!")
		return
	GameManager.current_player_name = entered_name
	get_tree().change_scene_to_file("res://components/story_screen.tscn")


func _on_continue_btn_mouse_entered() -> void:
	$hoverSoundPlayer.play()
