extends YSort

const DeathScn = preload("res://GameScns/UIScns/DeathUI/DeathScreen.tscn")
const PauseScn = preload("res://GameScns/UIScns/PauseUI/PauseScreen.tscn")
const WinScn = preload("res://GameScns/UIScns/WinUI/WinScreen.tscn")

var is_paused = false
onready var enemy = $ZhuRong
onready var skillUI = $CanvasLayer1/SkillUI

# Called when the node enters the scene tree for the first time.
func _ready():
	SplashBgm.stop_music()
	PlayerStats.num_skills = 3
	PlayerStats.connect("no_health", self, "_handle_death")
	enemy.stats.connect("no_health", self, "_handle_win")

func _unhandled_input(event):
	if(event.is_action_pressed("pause")):
		if(is_paused == false):
			var pause_menu = PauseScn.instance()
			add_child(pause_menu)
			is_paused = true
		else:
			is_paused = false

		
func _handle_death():
	var death_menu = DeathScn.instance()
	add_child(death_menu)
	
func _handle_win():
	var win_menu = WinScn.instance()
	add_child(win_menu)
#	skillUI.get_node("Earth/Sprite").visible = true
	
func _process(delta):
	if $BGM.playing == false:
		$BGM.play()

