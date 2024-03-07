extends Node
# corresponds to singleton State

# all game state variables are in here
# and get saved

# contains variables (mostly) only used by ActionScript
var data :Dictionary

# the name of the current location
var location :String

# the name of the location we come from
# might not be an actual location
var from :String

# the answer from the last prompt
var ans

# the one speaking currently
var speaker = null

func get_addr(var_name :String):
	if var_name in self:
		return "GameState[\"" + var_name + "\"]"
	if var_name in data:
		return "GameState.data[\"" + var_name + "\"]"
	return ""
