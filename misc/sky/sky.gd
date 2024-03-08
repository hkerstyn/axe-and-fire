extends Node3D

var rotation_speed = 1e-3

func _ready():
	var mesh = $SkyBox/Cube
	
	# set the material
	# to make sure the sky texture is sampled directly without
	# any light processing
	# uses sky.gdshader for that
	var material = preload("res://misc/sky/sky_shader_material.tres")
	mesh.set_surface_override_material(0,material)
	
	# the sun should not be occluded by the sky
	mesh.cast_shadow = 0
	
	# set the size of the skybox to really large
	scale = 500.0 * Vector3.ONE
	
func _process(delta):
	rotate_y(rotation_speed*delta)
