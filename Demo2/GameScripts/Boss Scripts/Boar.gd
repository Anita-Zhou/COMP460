extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var count = 0
var timer = 0
# var rng = RandomNumberGenerator.new()
var speed = 40
var direction = Vector2(0, 0)
var temp_direction = Vector2(0, 0)
var distance2hero = float("inf")
var anim_sprite = null
var player = null
var should_stop = false
enum{
	IDLE,
	WALK,
	CHARGE_PREP,
	CHARGE,
	STOP
}
var state = WALK

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")


# Called when the node enters the scene tree for the first time.
func _ready():
	anim_sprite = get_node("BoarAnimation")
	player = $"../Player"

func _physics_process(delta):
	direction = player.position - self.position
	direction = direction.normalized()
	distance2hero = self.position.distance_to(player.position)
	var motion = direction * speed
	#print("direction", direction)
	# if(count == 0):
	# 	direction.x = rng.randf_range(-2, 2)
	# 	direction.y = rng.randf_range(-2, 2)
	# 	count = 40
	# count -= 1
	animationTree.set("parameters/Walk/blend_position", direction)
	animationTree.set("parameters/ChargePrep/blend_position", direction)
	animationTree.set("parameters/Idle/blend_position", direction)
	
	match state:
		IDLE:
			motion = direction * 0
			if timer < 60:
				animationState.travel("Idle")
				timer = timer + 1
			else:
				state = WALK
				timer = 0
		WALK:
			motion = direction * speed
			if distance2hero > 300:
				animationState.travel("Walk")
			elif should_stop:
				state = STOP
			else:
				state = CHARGE_PREP
		CHARGE_PREP:
			motion = direction * 0
			if timer < 100:
				animationState.travel("ChargePrep")
				timer = timer + 1
			else:
				temp_direction = direction
				animationTree.set("parameters/Charge/blend_position", direction)
				state = CHARGE
				timer = 0
		CHARGE:
			motion = temp_direction * speed * 6
			if timer < 60:
				animationState.travel("Charge")
				timer = timer + 1
			else:
				state = IDLE
				timer = 0
		STOP:
			motion = direction * 0
			if timer < 100:
				animationState.travel("Walk")
				timer = timer + 1
			else:
				temp_direction = direction
				animationTree.set("parameters/Charge/blend_position", direction)
				state = WALK
				timer = 0

	
	move_and_slide(motion)
	move_and_collide(motion * delta)
	
	
		

func _process(delta):
	distance2hero = self.position.distance_to(player.position)
	
#	AnimationProcess()
#	if(count > 0):
#		count -= 1
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func AnimationProcess():
	if(direction.x < 0):
		anim_sprite.set_flip_h(false)
	else:
		anim_sprite.set_flip_h(true)
	anim_sprite.play("boar_run")
	# need to do more
	if(distance2hero < 150 and count == 0):
		print("stop and charge")
		should_stop = true
		#anim_sprite.stop()
		anim_sprite.play("boar_charge")
		anim_sprite.connect("animation_finished", self, "handle_charge_stop")
		print("boar_charge played")
		

func handle_charge_stop():
	print("handle_charge_stop")
	anim_sprite.disconnect("animation_finished", anim_sprite, "handle_charge_stop")
	should_stop = false
	print("should_stop", should_stop)
	anim_sprite.play("boar_run")
	print("replay run")
	count = 20
	
func fix_position(check):
	should_stop = check
	