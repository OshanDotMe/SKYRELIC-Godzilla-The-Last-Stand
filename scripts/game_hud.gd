extends CanvasLayer

@onready var health_bar: ProgressBar = $Control/ProgressBar
@onready var atomic_bar: ProgressBar = $Control/ProgressBar2
@onready var mothra_avatar: TextureRect = $Control/TextureRect2
@onready var score_label: Label = $Control/Label2
@onready var point_label: Label = $Control/Label3
@onready var pause_menu: ColorRect = $Control/ColorRect
@onready var game_over_menu: ColorRect = $Control/gameOverMenu

var mothra_used: bool = false

func _ready() -> void:
	pause_menu.visible = false
	health_bar.max_value = GameManager.max_health
	health_bar.value = GameManager.max_health

func _process(delta: float) -> void:
	score_label.text = "COINS: " + str(GameManager.score)
	point_label.text = "SCORE: " + str(GameManager.points)
	var player = get_tree().get_first_node_in_group("player")
	if player:
		atomic_bar.value = player.atomic_charge
		health_bar.value = player.health
	if Input.is_action_just_pressed("mothra_heal") and not mothra_used:
		use_mothra_ability()

func show_game_over() -> void:
	get_tree().paused = true
	game_over_menu.visible = true

func use_mothra_ability():
	mothra_used = true
	mothra_avatar.modulate = Color(0.2, 0.2, 0.2, 1.0)

func _on_button_3_pressed() -> void:
	get_tree().paused = true
	pause_menu.visible = true

func _on_resume_btn_pressed() -> void:
	get_tree().paused = false
	pause_menu.visible = false

func _on_main_menu_btn_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://components/main_menu.tscn")

func _on_close_game_btn_pressed() -> void:
	get_tree().quit()

func _on_retry_btn_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_button_3_mouse_entered() -> void:
	$hoverSoundPlayer.play()


func _on_resume_btn_mouse_entered() -> void:
	$hoverSoundPlayer.play()


func _on_main_menu_btn_mouse_entered() -> void:
	$hoverSoundPlayer.play()


func _on_close_game_btn_mouse_entered() -> void:
	$hoverSoundPlayer.play()


func _on_retry_btn_mouse_entered() -> void:
	$hoverSoundPlayer.play()
