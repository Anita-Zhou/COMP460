extends TextureButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_MainTxtBtn_button_up():
	print("=====pressed main menu button")
	PlayerStats.reset()
	get_tree().change_scene("res://Levels/SplashScreen.tscn")


func _on_button_up():
	pass # Replace with function body.
