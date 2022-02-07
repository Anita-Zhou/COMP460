extends Control

var health = 100 setget set_health
var max_health = 100 setget set_max_health

onready var label = $Label
onready var healthBar = $HealthBar
onready var update_tween = $UpdateTween

func set_health(value):
	health = clamp(value, 0, max_health)
	print("player set_health called")
	#emit_signal("health_updated")
	#update progress bar
	update_tween.interpolate_property(healthBar, "value", healthBar.value, \
	health, 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	update_tween.start()
	#update label
	#if label != null:
	#	label.text = "HP = " + str(health)

func set_max_health(value):
	max_health = max(value, 1)
	#emit_signal("max_health_updated")

# Called when the node enters the scene tree for the first time.
func _ready():
	self.max_health = PlayerStats.max_health
	self.health = PlayerStats.health
	PlayerStats.connect("health_changed", self, "set_health")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
