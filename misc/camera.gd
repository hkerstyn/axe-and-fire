extends Camera3D

const dir = Vector3(-4, 5, 0)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player_position = Global.find("Player").global_position
	global_position = player_position + dir
	look_at(player_position)
