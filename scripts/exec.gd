class_name Exec
extends Area3D

static func add(node :Node):
	var exec = Exec.new()
	var collision_shape = CollisionShape3D.new()
	
	var shape
	if node is MeshInstance3D:
		shape = node.mesh.create_convex_shape()
	else:
		shape = SphereShape3D.new()
		shape.radius = 0.1
	collision_shape.set_shape(shape)
	exec.add_child(collision_shape)
	node.add_child(exec)

func exec():
	print("exec!")
