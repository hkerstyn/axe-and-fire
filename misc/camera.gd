extends Camera3D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	look_at(Global.find("Player").global_position)
