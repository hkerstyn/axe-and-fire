extends Node
# From singleton

# a From node is where the player enters the scene

# the player scene to instantiate
var player_path = "res://player/player.tscn"

# deal with a From Node
func process(node, args):
	# check if this from is the actual from
	# we entered the scene in
	if args[0] == SceneLoader.from:
		# create the player at from
		SceneLoader.load_scene(player_path, node)
