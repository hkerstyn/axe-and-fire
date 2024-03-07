extends Polygon2D

const width = 20
const gap = 5
const height = 17

func _ready():
	color = Global.find("UI").theme.get("Panel/styles/panel").bg_color
	polygon = [Vector2(0, 0), Vector2(gap, 108-height), Vector2(gap+width,108-height)]

func set_origin(origin):
	if origin == null:
		hide()
		return
	show()
	
	var mouth = origin.get_node_or_null("Mouth")
	if mouth:
		origin = mouth
	polygon[0] = Global.find("Camera").unproject_position(origin.global_position)

	
