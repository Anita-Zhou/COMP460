extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var speed = 250
var move_direction = Vector2(0,0)


# Called when the node enters the scene tree for the first time.
func _ready():
	print ("Hello World")

	# pass # Replace with function body.
func _physics_process(delta):
	
	if(Input.get_action_strength("ui_right")):
		print("pressed d")

	move_direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	move_direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	var motion = move_direction * speed
	move_and_slide(motion)
	move_and_collide(motion * delta)

func _input(ev):
	if Input.is_key_pressed(KEY_SPACE):
		self.position = self.position + move_direction * speed/3
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		pass
			#play attck animation

# func _process(delta):
# 	pass
# 	# _animationLoop()

# func _movementLoop(delta):
# 	move_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
# 	move_direction.y = (int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))) / float(2)
	
# 	var motion = move_direction.normalized() * speed
# 	move_and_slide(motion)

# func _animationLoop():
# 	pass

