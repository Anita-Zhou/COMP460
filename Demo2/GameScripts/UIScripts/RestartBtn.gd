extends Button

onready var deathscn = get_tree().get_root().get_node("DeathScreen")

func _ready():
	pass # Replace with function body.

func _get_configuration_warning()->String:
	return "cannot load World1 scene"
