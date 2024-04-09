extends Node
#singleton MaterialLoader
var cache :Dictionary = {}

const dir = "res://shaders/"

func get_uniforms(shader):
	var uniform_objects = shader.get_shader_uniform_list()
	var uniforms = []
	for uniform_object in uniform_objects:
		uniforms.push_back(uniform_object.name)
	return uniforms


func set_property(property, value):
	for shader_material in cache.values():
		if property in get_uniforms(shader_material.shader):
			shader_material.set_shader_parameter(property, value)



func load(shader_name):
	if cache.has(shader_name):
		return cache[shader_name]
	
	var shader_material := ShaderMaterial.new()
	var shader = load(dir + shader_name + ".gdshader")
	shader_material.shader = shader
	
	var uniforms = get_uniforms(shader)
	
	for file in DirAccess.get_files_at(dir):
		if file.get_extension() in ["gdshader", "gdshaderinc"]:
			continue
		var uniform = file.get_basename()
		if uniform in uniforms:
			print(uniform)
			shader_material.set_shader_parameter(uniform, load(dir + "/" + file))
	
	cache[shader_name] = shader_material
	return shader_material

