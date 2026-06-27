extends Control


@onready var points_label = $Panel/Label4
@onready var health_btn = $Panel/healthBtn
@onready var charge_btn = $Panel/ChargeBtn
@onready var aura_btn = $Panel/AuraBtn
@onready var notification_lable = $Panel/notificationLable
@onready var health_info_lable = $Panel/healthLable
@onready var charge_info_lable = $Panel/chargeLable
@onready var aura_info_lable = $Panel/auraLable

func _ready() -> void:
	BackgroundMusic.set_menu_volume()
	notification_lable.modulate.a = 0.0
	update_shop_ui()

func update_shop_ui():
	points_label.text = str(GameManager.score)
	var hp_bar = get_progress_bar_string(GameManager.health_lvl, 5)
	var charge_bar = get_progress_bar_string(GameManager.charge_lvl, 5)
	var aura_bar = get_progress_bar_string(GameManager.aura_lvl, 5)
	health_info_lable.text = hp_bar + "  (Current: " + str(GameManager.max_health) + " HP)  - Cost: " + str(GameManager.health_upgrade_cost) + " PTS"
	charge_info_lable.text = charge_bar + "  (Current: " + str(GameManager.atomic_cooldown_time) + "s)  - Cost: " + str(GameManager.charge_upgrade_cost) + " PTS"
	aura_info_lable.text = aura_bar + "  (Current DMG: " + str(GameManager.radiation_aura_damage) + ")  - Cost: " + str(GameManager.aura_upgrade_cost) + " PTS"

func get_progress_bar_string(current_lvl: int, max_lvl: int) -> String:
	var bar = "["
	for i in range(1, max_lvl + 1):
		if i < current_lvl:
			bar += "■"
		else:
			bar += "□"
	bar += "]"
	return bar

func show_feedback(message: String, is_success: bool):
	notification_lable.text = message
	if is_success:
		notification_lable.add_theme_color_override("font_color", Color(0, 1, 0))
	else:
		notification_lable.add_theme_color_override("font_color", Color(1, 0, 0))
	var tween = create_tween()
	notification_lable.modulate.a = 1.0
	tween.tween_property(notification_lable, "modulate:a", 0.0, 1.5).set_delay(0.5)

func _on_health_btn_pressed() -> void:
	if GameManager.health_lvl >= 6:
		show_feedback("MAX LEVEL REACHED!", false)
		return
	if GameManager.score >= GameManager.health_upgrade_cost:
		GameManager.score -= GameManager.health_upgrade_cost
		GameManager.max_health += 50
		GameManager.health_lvl += 1
		GameManager.health_upgrade_cost = int(GameManager.health_upgrade_cost * 1.5)
		update_shop_ui()
		show_feedback("PURCHASE SUCCESSFUL: +50 MAX HP!", true)
	else:
		show_feedback("NOT ENOUGH POINTS!", false)

func _on_charge_btn_pressed() -> void:
	if GameManager.charge_lvl >= 6:
		show_feedback("MAX LEVEL REACHED!", false)
		return
	if GameManager.score >= GameManager.charge_upgrade_cost:
		GameManager.score -= GameManager.charge_upgrade_cost
		GameManager.atomic_cooldown_time -= 0.3
		GameManager.charge_lvl += 1
		GameManager.charge_upgrade_cost = int(GameManager.charge_upgrade_cost * 1.6)
		update_shop_ui()
		show_feedback("PURCHASE SUCCESSFUL: CHARGE SPEED UP!", true)
	else:
		show_feedback("NOT ENOUGH POINTS!", false)

func _on_aura_btn_pressed() -> void:
	if GameManager.aura_lvl >= 6:
		show_feedback("MAX LEVEL REACHED!", false)
		return
	if GameManager.score >= GameManager.aura_upgrade_cost:
		GameManager.score -= GameManager.aura_upgrade_cost
		GameManager.radiation_aura_damage += 20
		GameManager.aura_lvl += 1
		GameManager.aura_upgrade_cost = int(GameManager.aura_upgrade_cost * 1.7)
		update_shop_ui()
		show_feedback("PURCHASE SUCCESSFUL: RADIATION AURA UP!", true)
	else:
		show_feedback("NOT ENOUGH POINTS!", false)

func _on_back_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://components/main_menu.tscn")


func _on_health_btn_mouse_entered() -> void:
	$hoverSoundPlayer.play()


func _on_charge_btn_mouse_entered() -> void:
	$hoverSoundPlayer.play()


func _on_aura_btn_mouse_entered() -> void:
	$hoverSoundPlayer.play()


func _on_back_btn_mouse_entered() -> void:
	$hoverSoundPlayer.play()
