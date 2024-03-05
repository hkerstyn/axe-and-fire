class_name To
extends Node

static func process(node, args):
	var area = Area3D.new()
	var collisionShape = CollisionShape3D.new()
	var shape = node.mesh.create_convex_shape()
	collisionShape.set_shape(shape)
	node.add_child(area)
	area.add_child(collisionShape)
	
	# setup the enter signal
	area.body_entered.connect(
		Callable(To, "to").bind(args)
	)

# is called when some body enters a toNode
static func to(body :Node3D, args):
	if not body is Player:
		return
		
	var location = args[0].to_pascal_case()
	if args.size() == 2:
		var from = args[1].to_pascal_case()
		SceneLoader.load_location(location, from)
	else:
		SceneLoader.load_location(location)

