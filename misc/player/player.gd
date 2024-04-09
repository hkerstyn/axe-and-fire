class_name Player
extends CharacterBody3D
@onready var roll_pivot = $RollPivot
@onready var mesh = $RollPivot/Mesh
@onready var animation_player = $RollPivot/Mesh/AnimationPlayer
@onready var exec_area = $RollPivot/Mesh/ExecArea



const speed = 6
const fall_acceleration = 75
const dash_charge_fall_acceleration = 60
const air_roll_fall_acceleration = 15
const jump_speed = 20
const run_mult = 2
const double_tap_msecs = 500
const roll_duration = 500
const roll_mult = 3
const dash_time_mult = 3
const dash_mult = 4

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

func _ready():
	animation_player.play("Idle")

func exec():
	for area in exec_area.get_overlapping_areas():
		if area is Exec:
			frozen = true
			await area.exec()
			frozen = false		

func update_shader_values():
	MaterialLoader.set_property("player_position", global_position)
	MaterialLoader.set_property("player_velocity", velocity)


func get_direction():
	var left_dir = - Global.find("Camera").global_basis.x
	left_dir.y = 0
	left_dir = left_dir.normalized()
	var up_dir = - Global.find("Camera").global_basis.z
	up_dir.y = 0
	up_dir = up_dir.normalized()

	
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
	animation_player.play("Roll", 0.5)
	turn(Vector3(360, 0, 0))

func turn(v):
	var tween = get_tree().create_tween()
	roll_pivot.rotation_degrees = Vector3.ZERO
	tween.tween_property(roll_pivot, "rotation_degrees",v, roll_duration/1000.0)


func jump():
	velocity.y = jump_speed
	animation_player.play("Jump", 0.5)

func charge_dash(is_in_roll):
	dash_charge_active = true
	dash_charge_start = time
	if not is_in_roll:
		animation_player.play("ChargeDash", 0.5)
	
func dash(duration):
	dash_timeout = time + duration
	animation_player.play("Dash", 0.5)
	
func _physics_process(delta):
	# if the player is frozen, do nothing
	if frozen:
		animation_player.play("Idle", 0.5)
		return
	update_shader_values()
	# get current time
	time = Time.get_ticks_msec()

	# check what state we're in
	var is_in_roll = time < roll_timeout
	
	var is_in_dash = time < dash_timeout
	
	var is_in_run = not is_in_dash \
		and not is_in_roll \
		and is_on_floor() \
		and Input.is_action_pressed("nod")
		
	var is_in_walk = not is_in_dash \
		and not is_in_run \
		and not is_in_roll \
		and is_on_floor()
	
	var is_in_fall = not is_on_floor() \
		and not is_in_dash \
		and not is_in_roll \
		and not dash_charge_active \
		and velocity.y < 0.0

	# figure out horizontal direction
	if is_in_roll:
		direction = roll_direction
	else:
		direction = get_direction()
	
	# look in the current direction
	if direction != Vector3.ZERO:
		look_at(position - direction)
		if is_in_walk:
			animation_player.play("Walk", 0.5, 2.0)
		if is_in_run:
			animation_player.play("Run", 0.5, 1.2)
	
	# idle
	var is_idle = direction == Vector3.ZERO and is_in_walk
	if is_idle:
		animation_player.play("Idle", 0.5)
		
	if is_idle and Input.is_action_just_pressed("use"):
		exec()

	if is_in_fall:
		animation_player.play("Fall", 0.5)

	# stop dash if we stop
	if direction == Vector3.ZERO or velocity.length() < 0.1:
		dash_timeout = time
	
	if is_on_floor() and is_in_dash:
		animation_player.play("Dash", 0.5)
	
	if not is_on_floor() or is_in_roll or is_in_dash:
		if Input.is_action_just_pressed("use"):
			turn(Vector3(0, 360, 0))
			
	if not is_on_floor() or is_in_roll:		
		if Input.is_action_just_pressed("special"):
			turn(Vector3(-360, 0, 0))
	
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
			charge_dash(started_air_roll)
	
	# dash
	if not is_on_floor() \
		and Input.is_action_just_released("nod") \
		and dash_charge_active:
			dash_charge_active = false
			if not started_air_roll:
				dash(dash_time_mult * (time - dash_charge_start))
			elif not is_in_roll:
				dash(100000000000)
			else:
				roll_timeout = time
	
	var mult = 1.0
	if is_in_roll:
		mult = roll_mult
	elif is_in_run:
		mult = run_mult
	elif is_in_dash:
		mult = dash_mult
	
	var fall_acceleration = fall_acceleration
	if started_air_roll:
		fall_acceleration = air_roll_fall_acceleration
	elif dash_charge_active:
		fall_acceleration = dash_charge_fall_acceleration
	
	velocity.z = direction.z * speed * mult
	velocity.x = direction.x * speed * mult
			
	velocity.y += -fall_acceleration*delta
	move_and_slide()

