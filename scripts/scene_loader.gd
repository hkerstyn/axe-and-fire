extends Node
# singleton SceneLoader

# the parent node for location_node
#@onready var world_node :Node = $/root/Pixelizer/ViewportContainer/Viewport/World
@onready var world_node :Node = $/root/World

# the current location we are at
# gets freed when entering a new location
var location_node :Node = null

func load_scene(scene_path :String, parent_node :Node):
	var scene_resource = ResourceLoader.load(scene_path)
	var scene_node = scene_resource.instantiate()
	parent_node.add_child(scene_node)
	SceneProcessor.process(scene_node)
	return scene_node

func load_location(location, from=State.location):
	# do it deferred because we delete the old scene
	# this might cause trouble otherwise
	call_deferred("_deferred_load_location", location, from)
	
func _deferred_load_location(location, from):
	if location_node != null:
		location_node.free()
		
	State.from = from.to_pascal_case()
	State.location = location.to_pascal_case()
	# figure out the scene path
	var location_path = "res://scenes/" + location.to_snake_case() + ".blend"
	location_node = load_scene(location_path, world_node)


