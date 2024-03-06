class_name ActionScript
extends Node

# responsible for executing
# lines of action script

# the lines to execute
var lines :Array

# the scene context we're in
# (for local variable scoping)
var scene :String

# the arguments our scene was invoked in
var args :PackedStringArray = []

# whether or not the last if condition
# evaluated to true
var if_state = false

# the unprocessed options 
var options = []

# creates a new ActionScript object from 
# a scene name
static func load(scene:String):
	var action_script = ActionScript.new()
	# load file content as lines
	action_script.lines = Parser.load(scene)
	action_script.scene = scene
	return action_script

# runs this ActionScript
func exec():
	exec_lines(lines)

# executes the given lines in ActionScript
func exec_lines(lines :Array):
	while not lines.is_empty():
		var line = lines.pop_front().strip_edges()
		
		if line.begins_with("&"):
			exec_godot([line])
			continue
			
		if not line.ends_with(":"):
			print(line)
			continue
				
		var cmd_with_arg = Parser.split_cmd(line)
		var cmd = cmd_with_arg[0]
		var cmd_method = "cmd_" + cmd
		var cmd_arg = cmd_with_arg[1]
		
		if cmd == cmd.to_pascal_case():
			cmd_method = "cmd_say"
			cmd_arg = cmd
		
		call(cmd_method, cmd_arg, Parser.get_indent(lines))

func cmd_do(cmd_arg, lines):
	exec_godot([cmd_arg]+lines)

# executes lines of godot code
func exec_godot(code :Array):
	# make an action_script variable
	# so that the godot code can acess
	# this ActionScript object
	var gd_code = "var action_script\n"
	
	# add the lines to a function
	gd_code += "func eval():\n"
	for line in code:
		line = process_godot_line(line)
		gd_code += "\t" + line + "\n"
	
	return Parser.exec_godot(gd_code, self)

# replaces all &variables with
# actual valid expressions
func process_godot_line(line :String):
	# search for variables
	var regex = RegEx.new()
	regex.compile("&[a-z0-9_]+")
	for regex_match in regex.search_all(line):
		# extract the variable name, ie remove &
		var var_name = regex_match.get_string().right(-1)
	
		# figure out an address for the variable
		# ie a bit of godot code 
		var var_addr = ""
		
		# check if we have such a variable
		if var_name in self:
			# the variable action_script is set to our self
			var_addr = "action_script[\"" + var_name + "\"]"
			
		# otherwise, try a local variable
		if var_addr.is_empty():
			var_addr = GameState.get_addr(scene+"_"+var_name)
			
		# otherwise, try a global variable
		if var_addr.is_empty():
			var_addr = GameState.get_addr(var_name)
		
		# if nothing works, use an invalid address
		# so that godot will complain
		if var_addr.is_empty():
			var_addr = var_name+"_not_found"
		
		# replace the &variable expression with the address
		line = Parser.replace(regex_match, line, var_addr)
	return line
	
# declare local variables
func cmd_vars(cmd_arg, lines):
	for line in lines:
		if line.is_empty():
			continue
		
		# syntax: var_name = default_value
		var pair = line.split("=", false, 2)
		var var_name = scene + "_" + pair[0].strip_edges()
		
		# check if the variable already exists
		if not GameState.data.has(var_name):
			# if not, let the default value be false
			GameState.data[var_name] = false
			
			# unless an explicit value has been provided
			if pair.size() == 2:
				var value = pair[1]
				exec_godot(["&" + var_name + "="+value])

# displays the unhandled options
func flush_options():
	if options.is_empty():
		return
	for option in options:
		print(option)
	options = []
	
# gathers an option for later
func cmd_option(cmd_arg, lines):
	var pair = cmd_arg.split("=", false, 2)
	
	var option = ActionScriptOption.new()
	option.alias = pair[0]
	option.text = pair[-1]
	option.lines = lines
	
	options.push_back(option)
	
# executes the lines
# but restores if_state to its original afterwards
# to deal with nested ifs
func if_safe_exec_lines(lines):
	var old_if_state = if_state
	exec_lines(lines)
	if_state = old_if_state

func cmd_if(cmd_arg, lines):
	if_state = exec_godot(["return "+cmd_arg])
	
	if if_state == true:
		if_safe_exec_lines(lines)
	
func cmd_else(cmd_arg, lines):
	if if_state == false:
		if_safe_exec_lines(lines)

func cmd_elif(cmd_arg, lines):
	if if_state == false:
		cmd_if(cmd_arg, lines)
		

