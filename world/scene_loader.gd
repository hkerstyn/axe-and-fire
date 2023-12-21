extends Node
# corresponds to the SceneLoader singleton
# responsible for instantiating a scene
# as child of another scene

var world_path = "/root/Node2D/PixelizerViewportContainer/PixelizerViewport/World"

# instantiates a scene resource path at a specific parent node
func load_scene(scene :String, parent_path :NodePath =world_path):
	var scene_resource = ResourceLoader.load(scene)
	var current_scene = scene_resource.instantiate()
	var parent = get_node(parent_path)
	parent.add_child(current_scene)
