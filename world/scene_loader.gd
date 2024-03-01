extends Node
# singleton SceneLoader

# responsible for instantiating a scene
# as child of another scene

# which game scene is currently active
var current_game_scene = null
var current_game_scene_name = ""

# where we entered the current game scene from
var from = ""

# instantiates a scene resource path at a specific parent node
func load_scene(scene_path :String, parent :Node):
	var scene_resource = ResourceLoader.load(scene_path)
	var scene = scene_resource.instantiate()
	parent.add_child(scene)
	SceneProcessor.process(scene)
	return scene

# loads a scene into world_path
# deletes the former game_scene
# takes just the scene name as argument, not the path
# from is where we enter the scene from
func load_game_scene(scene_name, from=current_game_scene_name.to_pascal_case()):
	# do it deferred because we delete the old scene
	# this might cause trouble otherwise
	print(scene_name+", "+from)

	call_deferred("_deferred_load_game_scene", scene_name, from)
	
func _deferred_load_game_scene(scene_name, from):
	if current_game_scene != null:
		current_game_scene.free()
		
	SceneLoader.from = from
	current_game_scene_name = scene_name
	# figure out the scene path
	var scene_path = "res://scenes/" + scene_name + ".blend"
	current_game_scene = load_scene(scene_path, World.world)


