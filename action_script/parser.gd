class_name Parser
extends Node

# contains a few annoying functions
# used by ActionScript

# retreives lines of action script code
# given a scene_name
static func load(scene: String):
	var file_name = "res://action_script/" + scene + ".txt"
	var file = FileAccess.open(file_name, FileAccess.READ)
	return Array(file.get_as_text().split("\n"))

# figure out how many lines at the top
# are indented
# return them dedeneted
static func get_indent(lines :Array):
	var indented_lines = []
	while not lines.is_empty():
		if is_indented(lines[0]):
			var line = lines.pop_front().right(-1)
			indented_lines.push_back(line)
		else:
			break
	return indented_lines

static func is_indented(line :String):
	return line.begins_with("\t") or line.strip_edges().is_empty()

# splits a command line into the command name
# and the command argument
# syntax: cmd cmd_arg:
# returns [cmd, cmd_arg]
static func split_cmd(line :String):
	var pair = line.left(-1).split(" ", false, 1)
	if pair.size() == 1:
		pair.push_back("")
	return pair

# replaces the substr of line
# pointed to by regex_match
# with replacement
static func replace(regex_match, line, replacement):
	return line.left(regex_match.get_start()) \
			+ replacement \
			+ line.right(-regex_match.get_end())

# executes raw godot code
# sets the variable action_script
static func exec_godot(code :String, action_script :ActionScript):
	var script = GDScript.new()
	script.set_source_code(code)
	script.reload()
	var ref = RefCounted.new()
	ref.set_script(script)
	ref["action_script"] = action_script
	return ref.call("eval")
	
