class_name Player
extends CharacterBody3D
@onready var animation_player = $Mesh/AnimationPlayer

var jump_count = 0
@onready var left_dir = - get_parent().global_basis.z
@onready var up_dir = get_parent().global_basis.x

var speed = 4
var fall_acceleration = 75

var scale_animation_player

func play_animation(state):
	var state_machine = $AnimationTree["parameters/StateMachine/playback"]
	state_machine.travel(state)

func _physics_process(delta):
	if is_on_floor():
		jump_count = 0
		if Input.is_action_just_pressed("jump"):
			velocity.y = 10
			jump_count += 1
	elif jump_count == 1 and Input.is_action_just_pressed("jump"):
			velocity.y = 14
			jump_count += 1
			
	var direction = Vector3.ZERO
	if Input.is_action_pressed("ui_left"):
		direction += left_dir
	if Input.is_action_pressed("ui_right"):
		direction -= left_dir
	if Input.is_action_pressed("ui_up"):
		direction += up_dir
	if Input.is_action_pressed("ui_down"):
		direction -= up_dir
		
	if direction != Vector3.ZERO:
		play_animation("Walk")
		direction = direction.normalized()
		$Mesh.look_at(position-direction)
	else:
		play_animation("Idle")
	

	
	# horizontal movement
	velocity.z = direction.z * speed
	velocity.x = direction.x * speed

			
	velocity.y += -fall_acceleration*delta
	move_and_slide()

