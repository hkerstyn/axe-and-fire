extends Node
# corresponds to the SceneLoader singleton
# responsible for instantiating a scene
# as child of another scene

# where new scenes are loaded to by default
var world_path = "/root/Node2D/PixelizerViewportContainer/PixelizerViewport/World"

# which game scene is currently active
var current_game_scene = null
var current_game_scene_name = ""

# instantiates a scene resource path at a specific parent node
func load_scene(scene_path :String, parent_path :NodePath):
	var scene_resource = ResourceLoader.load(scene_path)
	var scene = scene_resource.instantiate()
	var parent = get_node(parent_path)
	parent.add_child(scene)
	SceneProcessor.process(scene)
	return scene

# loads a scene into world_path
# deletes the former game_scene
# takes just the scene name as argument, not the path
func load_game_scene(scene_name):
	# do it deferred because we delete the old scene
	# this might cause trouble otherwise
	call_deferred("_deferred_load_game_scene", scene_name)
	
func _deferred_load_game_scene(scene_name):
	if current_game_scene != null:
		current_game_scene.free()
		
	current_game_scene_name = scene_name
	# figure out the scene path
	var scene_path = "res://game_scenes/" + scene_name + ".blend"
	current_game_scene = load_scene(scene_path, world_path)


