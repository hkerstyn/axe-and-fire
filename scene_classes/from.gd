extends Node
class_name From

# a From node is where the player enters the scene

# the player scene to instantiate
const player_path = "res://player/player.tscn"

# deal with a From Node
static func process(node, args):
	# check if this from is the actual from
	# we entered the scene in
	if args[0].to_pascal_case() == State.from:
		# create the player at from
		SceneLoader.load_scene(player_path, node)
