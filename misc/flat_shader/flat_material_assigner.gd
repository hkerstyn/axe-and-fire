extends Node
class_name FlatMaterialAssigner

# assigns the flat shaded material
static func assign_flat_material(node):
	var material = preload("res://misc/flat_shader/flat_shader_material.tres")
	node.set_surface_override_material(0, material)
		
