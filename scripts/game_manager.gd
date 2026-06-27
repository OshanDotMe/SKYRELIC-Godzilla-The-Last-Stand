extends Node

var score: int = 0
var points: int = 0

#godzilla
var max_health: int = 200
var atomic_cooldown_time: float = 10.0
var radiation_aura_damage: int = 0

#upgrades
var health_lvl: int = 1
var health_upgrade_cost: int = 10
var charge_lvl: int = 1
var charge_upgrade_cost: int = 75
var aura_lvl: int = 1
var aura_upgrade_cost: int = 100

var current_player_name: String = ""

func _ready() -> void:
	SilentWolf.configure({
		"api_key": "GC9aqE0d7v9a5LTRerNpX8Y2DAfGYTTBjc1BfyV5",
		"game_id": "godzillalaststand",
		"log_level": 1
	})
	#SilentWolf.process_mode = Node.PROCESS_MODE_ALWAYS

func add_score(amount: int):
	score += amount
	print("Current Score: ", score)

func add_points(amount: int):
	points += amount
	print("Current Ponits: ", points)

func reset_game_data():
	score = 0
	points = 0

func upload_score_to_global(player_name: String, final_score: int) -> void:
	print("Uploading score to SilentWolf....")
	var score_id = await SilentWolf.Scores.save_score(player_name, final_score).sw_save_score_complete
	print("Global Score Upload Complete!")
