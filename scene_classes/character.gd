extends Node

# spawns a character 
static func process(node, args):
	var character = SceneLoader.load_scene(args[0])
	character.name = args[0]
	
	# adds a collider
	var collider = ResourceLoader.load("res://misc/character_collider.tscn").instantiate()
	character.add_child(collider)
	
	# plays the idle animation
	character.get_node("AnimationPlayer").play("Idle")
	
	var mouth = Node3D.new()
	mouth.name = "Mouth"
	character.add_child(mouth)
	mouth.position.y += 1.5
	
	# add it to the node
	Spawn.reduce(node).add_child(character)
	
