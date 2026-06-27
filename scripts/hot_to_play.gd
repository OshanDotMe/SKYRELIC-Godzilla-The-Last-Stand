extends Control


func _ready() -> void:
	BackgroundMusic.set_menu_volume()

func _on_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://components/main_menu.tscn")


func _on_button_3_mouse_entered() -> void:
	$hoverSoundPlayer.play()
