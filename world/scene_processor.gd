extends Node
class_name SceneProcessor

# do processing on any imported node
static func process(node):
	# assign flat material
	if node is MeshInstance3D:
		FlatMaterialAssigner.assign_flat_material(node)
		
	# consider the words the node name is made of
	var name_words = node.name.split(" ", false)
	var name = name_words[0]
	var args = name_words.slice(1)
	
	# match the first word (name) against all scene classes
	var dir = "res://scene_classes"
	for file in DirAccess.get_files_at(dir):
		var scene_class = file.get_basename().to_pascal_case()
		if scene_class == name:
			var SceneClass = load(dir + "/" + file)
			SceneClass.process(node, args)
			break
	
	# recurse children
	for child in node.get_children():
		process(child)
