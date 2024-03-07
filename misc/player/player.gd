class_name Player
extends CharacterBody3D
@onready var animation_player = $Mesh/AnimationPlayer

var jump_count = 0
@onready var left_dir = - get_parent().global_basis.z
@onready var up_dir = get_parent().global_basis.x

var speed = 4
var fall_acceleration = 75

func _physics_process(delta):
	return
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
		direction = direction.normalized()
		animation_player.play("Walk", 0.5, 2.0)
		$Mesh.look_at(position-direction)
	else:
		animation_player.play("Idle", 0.5)
	

	
	# horizontal movement
	velocity.z = direction.z * speed
	velocity.x = direction.x * speed

			
	velocity.y += -fall_acceleration*delta
	move_and_slide()
		
	if Input.is_action_just_pressed("use"):
		for area in $Mesh/ExecArea.get_overlapping_areas():
			if area is Exec:
				area.exec()
	

