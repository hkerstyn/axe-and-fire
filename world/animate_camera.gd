extends Camera3D
# creates a little camera animation

func _ready():
	var second_cam = $SecondCamera
	var tween = get_tree().create_tween()
	tween.tween_property(self, "transform", second_cam.get_global_transform(), 2)
	tween.set_loops()


