extends Node

# do processing on any imported node
func process(node):
	# assign flat material
	if node is MeshInstance3D:
		FlatMaterialAssigner.assign_flat_material(node)
		
	# recurse children
	for child in node.get_children():
		process(child)
