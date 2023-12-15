@tool
extends EditorScenePostImport

func _post_import(scene):
	assign_material_recursive(scene)
	return scene

func assign_material_recursive(node):
	if node == null:
		return
	
	if node is MeshInstance3D:
		var material = preload("res://flat_shader/flat_shader_material.tres")
		node.set_surface_override_material(0, material)
		
	for child in node.get_children():
		assign_material_recursive(child)
		
