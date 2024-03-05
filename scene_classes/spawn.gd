extends Node
class_name Spawn

# reduces a node to a simple Node3D
# with the same name and location
# this also removes all children
static func reduce(node):
	var dummy_node = Node3D.new()
	dummy_node.name = node.name
	dummy_node.transform = node.transform
	var parent_node = node.get_parent()
	node.queue_free()
	parent_node.add_child(dummy_node)
	return dummy_node

# spawns a scene at a given location
static func process(node, args):
	var scene = SceneLoader.load_scene(args[0])
	reduce(node).add_child(scene)
	
