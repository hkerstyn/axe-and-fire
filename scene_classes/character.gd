extends Node

static func process(node, args):
	var collider = ResourceLoader.load("res://misc/character_collider.tscn").instantiate()
	var character = SceneLoader.load_scene(args[0])
	character.name = args[0]
	character.add_child(collider)
	character.get_node("AnimationPlayer").play("Idle")
	Spawn.reduce(node).add_child(character)
