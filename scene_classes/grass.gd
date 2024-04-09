extends Node
const density = 20


static func process(node, args):
	if not node is MeshInstance3D:
		return
		
	# init multi_mesh instance
	var multi_mesh_instance = MultiMeshInstance3D.new()
	var multi_mesh := MultiMesh.new()
	multi_mesh.mesh = load("res://herbs/grass.blend") \
		.instantiate() \
		.find_children("*", "MeshInstance3D")[0] \
		.mesh
	multi_mesh.transform_format = MultiMesh.TRANSFORM_3D
	multi_mesh.mesh.surface_set_material(0, MaterialLoader.load("grass"))	
	multi_mesh_instance.multimesh = multi_mesh
	node.add_child(multi_mesh_instance)
	
	# assign positions
	var positions = get_positions(node.mesh)
	
	multi_mesh.instance_count = positions.size()
	for i in range(multi_mesh.instance_count):
		multi_mesh.set_instance_transform(i, Transform3D().translated(positions[i]))


static func get_positions(mesh:Mesh):
	var positions = []
	var mesh_data = mesh.surface_get_arrays(0)
	var indices = mesh_data[Mesh.ARRAY_INDEX]
	var vertices = mesh_data[Mesh.ARRAY_VERTEX]

	for i in range(0, indices.size(), 3):
		var origin = vertices[indices[i]]
		var a = vertices[indices[i + 1]] - origin 
		var b = vertices[indices[i + 2]] - origin
		var area = a.cross(b).length() * 0.5
		
		var count = area * density as int
		for _i in range(count):
			var alpha = randf()
			var beta = randf()
			if alpha + beta > 1:
				alpha = 1 - alpha
				beta = 1 - beta
			positions.push_back(origin + alpha * a + beta * b)
	return positions
