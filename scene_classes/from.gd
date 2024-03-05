extends Node

# a From node is where the player enters the scene

# the player scene to instantiate
const player_path = "res://misc/player/player.tscn"

# deal with a From Node
static func process(node, args):
	# check if this from is the actual from
	# we entered the scene in
	if args[0].to_pascal_case() == State.from:
		# create the player at from
		var Player = ResourceLoader.load(player_path)
		node.add_child(Player.instantiate())
