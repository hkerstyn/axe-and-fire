extends CharacterBody3D
@onready var animation_player = $Mesh/AnimationPlayer

var jump_count = 0
var left_dir = Vector3.FORWARD
var up_dir = Vector3.RIGHT
var speed = 4
var fall_acceleration = 75

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
	
	if velocity.y > 0.3:
		animation_player.play("Jump")
	

