class_name Exec
extends Area3D

# exec() gets executed upon player interaction
var action_script :String

# adds an exec to a node
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
	return exec

func set_action_script(action_script :String):
	self.action_script = action_script

func exec():
	await ActionScript.load(action_script).exec()
