extends Node
# singleton SceneProcessor

# do processing on any imported node
func process(node):
	# assign flat material
	if node is MeshInstance3D:
		FlatMaterialAssigner.assign_flat_material(node)
		
	# consider the words the node name is made of
	var name_words = node.name.split(" ", false)
	if name_words[0] == "From":
		From.process(node, name_words)
		
	if name_words[0] == "To":
		To.process(node, name_words)
		
	# recurse children
	for child in node.get_children():
		process(child)
