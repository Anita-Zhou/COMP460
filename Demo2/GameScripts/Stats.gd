extends Node

export(int) var max_health = 100
onready var health = max_health setget set_health

signal no_health

func _ready():
	pass 

func set_health(value):
	health = value
	if health <= 0:
		emit_signal("no_health")
