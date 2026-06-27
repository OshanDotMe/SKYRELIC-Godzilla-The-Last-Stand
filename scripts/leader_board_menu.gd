extends Control

@onready var score_container: VBoxContainer = $ColorRect/ScrollContainer/VBoxContainer

func _ready() -> void:
	BackgroundMusic.set_menu_volume()
	get_tree().paused = false
	await get_tree().create_timer(0.1, false).timeout
	clear_container()
	var loading_label = Label.new()
	loading_label.text = "Loading Global Scores..."
	loading_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_container.add_child(loading_label)
	var score_request = SilentWolf.Scores.get_scores()
	var sw_result = await score_request.sw_get_scores_complete
	var global_scores = sw_result.scores
	clear_container()
	if global_scores.size() == 0:
		var no_score = Label.new()
		no_score.text = "No High Scores Yet World Wide!"
		no_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		score_container.add_child(no_score)
	else:
		var rank = 1
		for entry in global_scores:
			var score_label = Label.new()
			score_label.text = str(rank) + ". " + str(entry.player_name) + "  -  " + str(entry.score)
			score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			score_label.add_theme_font_size_override("font_size", 24)
			score_container.add_child(score_label)
			rank += 1

func clear_container():
	for child in score_container.get_children():
		child.queue_free()

func _on_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://components/main_menu.tscn")


func _on_button_3_mouse_entered() -> void:
	$hoverSoundPlayer.play()
