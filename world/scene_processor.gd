extends Node
# singleton SceneProcessor

# returns an array of all object classes
func get_scene_classes():
	var files = DirAccess.get_files_at("res://scene_classes")
	var scene_classes = []
	for file in files:
		scene_classes.push_back(file.get_basename().to_pascal_case())
	return scene_classes

# do processing on any imported node
func process(node):
	# assign flat material
	if node is MeshInstance3D:
		FlatMaterialAssigner.assign_flat_material(node)
		
	# consider the words the node name is made of
	var name_words = node.name.split(" ", false)
	var name = name_words[0]
	var args = name_words.slice(1)
	
	for scene_class in get_scene_classes():
		if name == scene_class:
			get_node("/root/" + scene_class).process(node, args)
	
	# recurse children
	for child in node.get_children():
		process(child)
