extends KinematicBody2D

var FRAME_RATE = 60

# Sppeds
var speed = 40
# Directions
var direction2hero = Vector2(0, 0)
var horizontal_dirc2hero = Vector2(0, 0)
var direction_to_mid = Vector2(0, 0)
var temp_direction = Vector2(0, 0)
# Distances
var distance2hero = float("inf")
var horizontal_dist2hero = float("inf")

var anim_sprite = null
var player = null
var second_phase = false
var second_phase_sound_played = false
enum{
	IDLE,
	MOVE,
	MOVE_STAFF, 
	MELEE_ATK,
	ENRAGE,
	STOP
}
var state = IDLE
var rng = RandomNumberGenerator.new()

onready var screenSize = get_viewport().get_visible_rect().size
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var stats = $Stats

#fixed point
onready var mid_scrn = Vector2.ZERO
onready var player_pos = Vector2.ZERO
onready var left_edge = Vector2.ZERO
onready var right_edge = Vector2.ZERO

# Timers for scripts
var timer = 0
var stop_timer = 0 # timer for wood skill
# Skill timer
var fireball_timer = 0
var fireball_timer2 = 0
var firebeam_timer = 0
var lava_timer = 0
var meleeAtk_timer = 0
var playerAway_timer = 0
var chase_timer = 0

# Helper var
var meleeAtk = false
var arrived = false
# Combined timer check 
var ready_to_cast = false
var ready_to_atk = true

var rageFire = null

#skills
onready var fireBall = get_node("FireBall")
onready var lavaPond = get_node("LavaPond")
onready var fireBeam = get_node("FireBeam")

# Called when the node enters the scene tree for the first time.
func _ready():
	anim_sprite = get_node("AnimatedSprite")
	player = get_parent().get_node("Player")
	# Can only be set once by this, indicating the center of the screen
	#  where all casting os spells happneing 
	mid_scrn = self.global_position
	player_pos = player.global_position
	

# Debug
var prev_state = IDLE

func _physics_process(delta):
	
	## DEBUG! 
	if(prev_state != state):
		print( "State change from ", prev_state, " to ", state)
	prev_state = state
	
	# If player is not dead, calculate distance and direction between boss and hero.
	if(is_instance_valid(player)):
		direction2hero = player.position - self.position
		distance2hero = self.position.distance_to(player.position)
		horizontal_dist2hero = abs(self.position.x - player.position.x)
	direction2hero = direction2hero.normalized()
	# Decide horizontal moving direction
	horizontal_dirc2hero = Vector2(direction2hero.x, 0).normalized()
	# Deicide the way back 
	direction_to_mid = (mid_scrn - self.position).normalized()
	
	# Combined state detect
	if (fireball_timer > FRAME_RATE * 5 or firebeam_timer > FRAME_RATE * 20):
		ready_to_cast = true
	if (playerAway_timer > FRAME_RATE * 30 or meleeAtk_timer > FRAME_RATE * 40):
		ready_to_atk = true
	
	# Update timers
	fireball_timer += 1
	firebeam_timer += 1
	meleeAtk_timer += 1
	
	# Second phase random generation of lava pools
	# TODO: lava pools are generated random within a frame close to player's position
	if(second_phase):
		if rageFire == null:
			var RageFire = load("res://GameScns/BossScns/RageFire.tscn")
			rageFire = RageFire.instance()
			var boss = get_tree().current_scene.get_node("ZhuRong")
			boss.add_child(rageFire)
			
		if horizontal_dist2hero < 300 and fireball_timer2 > FRAME_RATE * 5:
			fireBall.being_cast(direction2hero)
			fireBall.being_cast(direction2hero)
			fireBall.being_cast(direction2hero)
			fireball_timer2 = 0
		fireball_timer2 += 1
#			# TODO: index
#		if second_phase_sound_played == false:
#			$Second_phase.play()
#			second_phase_sound_played = true
		
		if(lava_timer < FRAME_RATE * 2):
			lava_timer = lava_timer + 1
		else:
			var lava_pos = Vector2(rng.randi_range(0,screenSize.x), rng.randi_range(250,screenSize.y-100))
			lavaPond.being_cast(lava_pos)
			lava_timer = 0

	var motion = direction2hero * speed
	animationTree.set("parameters/Idle/blend_position", direction2hero)
	animationTree.set("parameters/Move/blend_position", direction2hero)
	animationTree.set("parameters/MoveStaff/blend_position", direction2hero)
	animationTree.set("parameters/MeleeAttack/blend_position", direction2hero)
	
	match state:
		
		IDLE:
			motion = Vector2.ZERO
			animationState.travel("Idle")
			# Prioritize melee attack when player's been away for too long
			if (ready_to_atk):
				# Designated to state in cahrge of throw melee attack
				state = MELEE_ATK
			# If able to cast skills, cast skills
			elif (ready_to_cast):
				state = MOVE_STAFF
			# If player is away but not for too long, horizontally trace player
			elif (horizontal_dist2hero > 40):
				state = MOVE

		# Horizontally move, either go for melee attack or go for idle
		MOVE:
			motion = horizontal_dirc2hero * 20
			animationState.travel("Move")
			if (ready_to_atk):
				print("ready_to_atk")
				state = MELEE_ATK
			elif (ready_to_cast):
				print("ready_to_cast")
				state = MOVE_STAFF
		
		# Prepare to cast magic attack, decide on what magic attacj to do
		MOVE_STAFF:
			motion = Vector2.ZERO
			# Prepare for attack
			animationState.travel("MoveStaff")
			
		ENRAGE:
			# Display rage melee right after enraged
			$Second_phase.play()
			state = MELEE_ATK
			
		MELEE_ATK:
			if (distance2hero < 30 || chase_timer > FRAME_RATE * 6):
				arrived = true
				chase_timer = 0
			# If has neither arrived nor attacked
			if(!arrived && !meleeAtk):
				# Move towards player
				motion = direction2hero * 100
				animationState.travel("Move")
				chase_timer += 1
			# If has arrived but has not attack
			elif(arrived && !meleeAtk):
				motion = Vector2.ZERO
				# ATTACK based on phase
				# Phase 1
				if (!second_phase):
					animationState.travel("MeleeAttack")
				# Phase 2
				else:
					animationState.travel("RageMelee")
			# If has arrived and has attacked 
			elif(arrived && meleeAtk):
				# Getting back to center
				motion = direction_to_mid * 90
				animationState.travel("Move")
				# If have gotten back to mid screen, change to IDLE
				if (self.position.distance_to(mid_scrn) < 30):
					state = IDLE
					# Back to as if has never throw melee attack
					arrived = false
					meleeAtk = false
					meleeAtk_timer = 0
					playerAway_timer = 0
					# Reset ready_to_atk
					ready_to_atk = false
			else:
				print("===== ERROR: has not arrived but attacked =====")

		# Being stopped by the vines
		STOP:
			motion = horizontal_dirc2hero * 0
			if stop_timer < 180:
				animationState.travel("Idle")
				stop_timer = stop_timer + 1
			else:
				temp_direction = horizontal_dirc2hero
				state = MOVE
				timer = 0
			
	move_and_slide(motion)
	move_and_collide(motion * delta)

func get_stats():
	return self.stats

func get_direction2hero():
	return direction2hero

func back_to_normal():
	# move state to idle
	state = IDLE

# Helper function that modify meleeAtk after finished boss melee attack
func finished_melee_attack():
	meleeAtk = true
	
func handle_magic_cast():
	# Prioritize firebeam
	if (firebeam_timer > FRAME_RATE * 14):
		var fireBeamChoices = [2,3,4]
		var fireBeamNum = fireBeamChoices[randi() % fireBeamChoices.size()]
		
		while fireBeamNum > 0:
			var dirChosen = null
			if fireBeamNum > 1:	
				var dirChoices = [1, 2, 3]
				dirChosen = dirChoices[randi() % dirChoices.size()]
			else:
				dirChosen = 2
			fireBeam.being_cast(dirChosen)
			fireBeamNum -= 1
		firebeam_timer = 0
		fireball_timer = 0
	# Then consider fireball
	elif (fireball_timer > FRAME_RATE * 5):
		if (horizontal_dist2hero < 300):
			fireBall.being_cast(direction2hero)
			fireball_timer = 0
	# Always get back to IDLE after casting magic
	state = IDLE
	# Reset ready_to_cast so that it can prepare for 
	ready_to_cast = false

func _on_Hurtbox_area_entered(area):
	print(area.get_parent().get_name() + " entered boss")
	if("WoodIdle" in area.get_parent().get_name()):
		fix_position(false)
	elif("WoodSkill" in area.get_parent().get_name()):
		fix_position(true)
	else:
		take_damage(area)
	if stats.health < stats.max_health/2:
		second_phase = true

func fix_position(check):
	if(!check):
		stop_timer = 90
		if(state != IDLE):
			state = IDLE
	else:
		stop_timer = stop_timer - 90

func take_damage(area):
	#TODO: distinguish area 
	stats.health -= 70
#	emit_signal("boss_damage")
	animationPlayer.play("Hurt")
	print("zhu rong health", stats.health)


func _on_Stats_no_health():
	queue_free()


func _on_Stats_half_health():
	state = ENRAGE
