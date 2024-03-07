extends Node
# singleton SceneLoader

# the parent node for location_node
#@onready var world_node :Node = $/root/Pixelizer/ViewportContainer/Viewport/World
@onready var world_node :Node = $/root/World

# the current location we are at
# gets freed when entering a new location
var location_node :Node = null

func load_scene(scene :String):
	# figure out the path to the scene
	var scene_path = "res://scenes/" + scene.to_snake_case() + ".blend"
	var scene_resource = ResourceLoader.load(scene_path)
	var scene_node = scene_resource.instantiate()
	scene_node.name = scene.to_pascal_case()
	SceneProcessor.process(scene_node)
	return scene_node

func load_location(location, from=GameState.location):
	if location_node != null:
		location_node.queue_free()
		
	GameState.from = from.to_pascal_case()
	GameState.location = location.to_pascal_case()
	# figure out the scene path
	location_node = load_scene(location)
	world_node.add_child(location_node)


