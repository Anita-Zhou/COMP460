extends Button

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

	
func _on_MainBtn_button_up():
	print("=====pressed main menu button")
	get_tree().change_scene("res://GameScns/UIScns/SplashScreen.tscn")
