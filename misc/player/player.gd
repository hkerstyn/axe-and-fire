class_name Player
extends CharacterBody3D
@onready var animation_player = $Mesh/AnimationPlayer

@onready var left_dir = - get_parent().global_basis.z
@onready var up_dir = get_parent().global_basis.x

const speed = 6
const fall_acceleration = 75
const air_roll_fall_acceleration = 20
const jump_speed = 30
const run_mult = 1
const double_tap_msecs = 500
const roll_duration = 500
const roll_mult = 1
const dash_time_mult = 2
const dash_mult = 3

var frozen = false
var double_jumped = false
var last_nod_tap = 0
var roll_timeout = 0
var dash_charge_start = 0
var dash_charge_active = false
var dash_timeout = 0
var started_air_roll = false

var roll_direction = Vector3.ZERO

var time = 0
var direction

func exec():
	for area in $Mesh/ExecArea.get_overlapping_areas():
		if area is Exec:
			frozen = true
			await area.exec()
			frozen = false		

func get_direction():
	var direction = Vector3.ZERO
	
	if Input.is_action_pressed("left"):
		direction += left_dir
	if Input.is_action_pressed("right"):
		direction -= left_dir
	if Input.is_action_pressed("up"):
		direction += up_dir
	if Input.is_action_pressed("down"):
		direction -= up_dir
		
	if direction != Vector3.ZERO:
		direction = direction.normalized()
	return direction


func roll():
	roll_timeout = time + roll_duration
	roll_direction = direction
	dash_timeout = time

func jump():
	velocity.y = jump_speed

func charge_dash():
	dash_charge_active = true
	dash_charge_start = time
	
func dash(duration):
	dash_timeout = time + duration
	
func _physics_process(delta):
	# if the player is frozen, do nothing
	if frozen:
		animation_player.play("Idle", 0.5)
		return
	
	# get current time
	time = Time.get_ticks_msec()

	# check what state we're in
	var is_in_roll = time < roll_timeout
	
	var is_in_dash = time < dash_timeout
	
	var is_in_run = not is_in_dash \
		and not is_in_roll \
		and is_on_floor() \
		and Input.is_action_pressed("nod")
	
	# figure out horizontal direction
	if is_in_roll:
		direction = roll_direction
	else:
		direction = get_direction()
	
	# look in the current direction
	if direction != Vector3.ZERO:
		$Mesh.look_at(position + direction)

	# stop dash if we stop
	if direction == Vector3.ZERO or velocity.length() < 0.1:
		dash_timeout = time
	
	# reset shit if we're on the ground
	if is_on_floor():
		started_air_roll = false
		double_jumped = false
		dash_charge_active = false

	# start a roll, possibly an air roll
	if not is_in_roll and Input.is_action_just_pressed("nod"):
		# check for double tap
		if time - last_nod_tap < double_tap_msecs:
			roll()
			if not is_on_floor():
				started_air_roll = true
				velocity.y = 0
		# record current tap for next double tap
		else:
			last_nod_tap = Time.get_ticks_msec()
	
	# jump from the ground
	if is_on_floor() \
		and Input.is_action_just_pressed("jump") \
		and not is_in_roll:
			jump()
	
	# double jump		
	if not is_on_floor() \
		and Input.is_action_just_pressed("jump") \
		and not double_jumped \
		and velocity.y < 0.0:
			jump()
			double_jumped = true

	# charge dash
	if not is_on_floor() \
		and Input.is_action_just_pressed("nod"):
			charge_dash()
	
	# dash
	if not is_on_floor() \
		and Input.is_action_just_released("nod") \
		and dash_charge_active:
			dash_charge_active = false
			if not started_air_roll:
				dash(dash_time_mult * (time - dash_charge_start))
			elif not is_in_roll:
				dash(100000000000)
	
	var mult = 1.0
	if is_in_roll:
		mult = roll_mult
	elif is_in_run:
		mult = run_mult
	elif is_in_dash:
		mult = dash_mult
	
	var fall_acceleration = fall_acceleration
	if is_in_roll:
		fall_acceleration = air_roll_fall_acceleration
	
	velocity.z = direction.z * speed * mult
	velocity.x = direction.x * speed * mult
			
	velocity.y += -fall_acceleration*delta
	move_and_slide()

