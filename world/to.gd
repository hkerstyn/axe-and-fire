extends Node
# singleton To

func process(node, args):
	var area = Area3D.new()
	var collisionShape = CollisionShape3D.new()
	var shape = node.mesh.create_convex_shape()
	collisionShape.set_shape(shape)
	node.add_child(area)
	area.add_child(collisionShape)
	
	# setup the enter signal
	area.body_entered.connect(
		Callable(to).bind(args)
	)

# is called when some body enters a toNode
func to(body :Node3D, args):
	if not body is Player:
		return
		
	var new_scene = args[1].to_snake_case()
	if args.size() == 3:
		var from = args[2].to_pascal_case()
		SceneLoader.load_game_scene(new_scene, from)
	else:
		SceneLoader.load_game_scene(new_scene)

