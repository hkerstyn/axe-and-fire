extends Node

# assigns the flat shaded material
func assign_flat_material(node):
	var material = preload("res://flat_shader/flat_shader_material.tres")
	node.set_surface_override_material(0, material)
		
