extends Control

@onready var story_label = $storyLabel
@onready var skip_label = $skipLabel
var is_typing_done = false

func _ready() -> void:
	BackgroundMusic.set_gameplay_volume()
	var blink_tween = create_tween().set_loops()
	blink_tween.tween_property(skip_label, "modulate:a", 1.0, 0.6)
	blink_tween.tween_property(skip_label, "modulate:a", 0.2, 0.6)
	skip_label.modulate.a = 0.5
	story_label.bbcode_enabled = true
	story_label.text = "[center]Dreadful Boss Enemies have invaded the city, leaving total destruction in their wake...\n\nAwakened by the chaos, [color=red]GODZILLA[/color] rises from the deep ocean to reclaim his territory.\n\nHowever, the military forces mistake Godzilla for an enemy and launch a full-scale attack!\n\n[color=yellow]Can you survive and defeat the Titans?[/color][/center]"
	story_label.visible_characters = 0
	var tween = create_tween()
	$StoryTelling.play()
	tween.tween_property(story_label, "visible_ratio", 1.0, 17.0)
	await tween.finished
	is_typing_done = true

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		start_the_game()

func start_the_game():
	get_tree().change_scene_to_file("res://components/main.tscn")
