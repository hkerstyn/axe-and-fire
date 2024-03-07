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
var args :Array = []

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
		
		if line.is_empty():
			continue
		
		if line.begins_with("#"):
			continue
		
		if line.begins_with("&"):
			exec_godot([line])
			continue
			
		line = subst_line(line)
			
		if line.begins_with("@"):
			exec_scene_line(line)
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

func subst_line(line):
	var regex = RegEx.new()
	regex.compile("{.*}")
	while true:
		var regex_match = regex.search(line)
		if regex_match == null:
			break
			
		var exp = regex_match.get_string() \
			.trim_prefix("{").trim_suffix("}")
		var value = eval_godot(exp)
		
		line = Parser.replace(regex_match, line, str(value))
	return line 

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
	
func eval_godot(exp:String):
	return exec_godot(["return "+exp])

# replaces all &variables with
# actual valid expressions
func process_godot_line(line :String):
	# search for variables
	var regex = RegEx.new()
	regex.compile("&[a-z0-9_]+")
	while true:
		var regex_match = regex.search(line)
		if regex_match == null:
			break
			
		var var_name = regex_match.get_string().trim_prefix("&")
	
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

func init_vars(lines, assign_values):
	for line in lines:
		if line.is_empty():
			continue
		
		# syntax: var_name = default_value
		var pair = line.split("=", false, 2)
		var var_name = scene + "_" + pair[0].strip_edges()
		
		# if the variable doesnt exist,
		# set it to the default value false
		if not GameState.data.has(var_name):
			GameState.data[var_name] = false
			
			# unless an explicit value has been provided
			if pair.size() == 2:
				var value = pair[1]
				exec_godot(["&" + var_name + "="+value])
		
		# if an assign_value has been provided,
		# assign it instead
		if not assign_values.is_empty():
			GameState.data[var_name] = assign_values.pop_front()

func cmd_args(cmd_arg, lines):
	init_vars(lines, args)
	
func cmd_vars(cmd_arg, lines):
	init_vars(lines, [])

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

func exec_scene_line(line :String):
	line = line.trim_prefix("@")
	var words = line.split(" ", false)
	var scene = words[0]
	var action_script = ActionScript.load(scene)
	action_script.args = words.slice(1)
	await action_script.exec()
	options += action_script.options

# executes the lines
# but restores if_state to its original afterwards
# to deal with nested ifs
func if_safe_exec_lines(lines):
	var old_if_state = if_state
	exec_lines(lines)
	if_state = old_if_state

func cmd_if(cmd_arg, lines):
	if_state = eval_godot(cmd_arg)
	
	if if_state == true:
		if_safe_exec_lines(lines)
	
func cmd_else(cmd_arg, lines):
	if if_state == false:
		if_safe_exec_lines(lines)

func cmd_elif(cmd_arg, lines):
	if if_state == false:
		cmd_if(cmd_arg, lines)
		

