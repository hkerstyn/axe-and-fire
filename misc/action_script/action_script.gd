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

# whether execution should quit or not
var quit = false

#region load
# creates a new ActionScript object from 
# a scene name
static func load(scene:String):
	# load file
	var file_name = "res://action_scripts/" + scene + ".txt"
	var file = FileAccess.open(file_name, FileAccess.READ)
	var lines = Array(file.get_as_text().split("\n"))
	
	#make action_script
	var action_script = ActionScript.new()
	action_script.lines = lines
	action_script.scene = scene
	return action_script
#endregion


#region parse
# figure out how many lines at the top
# are indented
# return them dedeneted
static func get_indent(lines :Array):
	var indented_lines = []
	while not lines.is_empty():
		if is_indented(lines[0]):
			var line = lines.pop_front().trim_prefix("\t")
			indented_lines.push_back(line)
		else:
			break
	return indented_lines

static func is_indented(line :String):
	return line.begins_with("\t") or line.strip_edges().is_empty()

# replaces the substr of line
# pointed to by regex_match
# with replacement
static func replace(regex_match, line, replacement):
	return line.left(regex_match.get_start()) \
			+ replacement \
			+ line.right(-regex_match.get_end())
#endregion


#region exec_as
# runs this ActionScript
func exec():
	await exec_lines(lines.duplicate())
	await Global.new_page()

# executes the given lines in ActionScript
func exec_lines(lines :Array):
	while not lines.is_empty():
		var line = lines.pop_front().strip_edges()
		
		if line.is_empty():
			await Global.new_page()
			continue
		
		if line.begins_with("#"):
			continue
		
		if line.begins_with("&"):
			await exec_godot([line])
			continue
			
		line = await subst_brace_exps(line)
			
		if line.begins_with("@"):
			await exec_scene_line(line)
			continue
			
		if not line.ends_with(":"):
			await flush_options()
			if quit:
				return
			await Global.print(line)
			continue
				
		var cmd_with_arg = split_cmd(line)
		var cmd = cmd_with_arg[0]
		var cmd_method = "cmd_" + cmd
		var cmd_arg = cmd_with_arg[1]
		
		if cmd == cmd.to_pascal_case():
			cmd_method = "cmd_say"
			cmd_arg = cmd
		
		await call(cmd_method, cmd_arg, get_indent(lines))
		if quit:
			return

# splits a command line into the command name
# and the command argument
# syntax: cmd cmd_arg:
# returns [cmd, cmd_arg]
static func split_cmd(line :String):
	var pair = line.trim_suffix(":").split(" ", false, 1)
	if pair.size() == 1:
		pair.push_back("")
	return pair
	
func exec_scene_line(line :String):
	line = line.trim_prefix("@")
	var words = line.split(" ", false)
	var scene = words[0]
	var action_script = ActionScript.load(scene)
	action_script.args = words.slice(1)
	await action_script.exec()
	options += action_script.options
	quit = action_script.quit
#endregion


#region subst
func subst_brace_exps(line):
	var regex = RegEx.new()
	regex.compile("{.*}")
	while true:
		var regex_match = regex.search(line)
		if regex_match == null:
			break
			
		var exp = regex_match.get_string() \
			.trim_prefix("{").trim_suffix("}")
		var value = await eval_godot(exp)
		
		line = replace(regex_match, line, str(value))
	return line 

# replaces all &variables with
# actual valid expressions
func subst_vars(line :String):
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
		line = replace(regex_match, line, var_addr)
	return line
#endregion


#region exec_godot
func cmd_do(cmd_arg, lines):
	await exec_godot([cmd_arg]+lines)


# executes lines of godot code
func exec_godot(code :Array):
	# make an action_script variable
	# so that the godot code can acess
	# this ActionScript object
	var gd_code = "var action_script\n"
	
	# add the lines to a function
	gd_code += "func eval():\n"
	for line in code:
		line = subst_vars(line)
		gd_code += "\t" + line + "\n"
	
	var script = GDScript.new()
	script.set_source_code(gd_code)
	script.reload()
	var ref = RefCounted.new()
	ref.set_script(script)
	ref["action_script"] = self
	return await ref.call("eval")



func eval_godot(exp:String):
	return await exec_godot(["return "+exp])
#endregion


#region vars
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
				await exec_godot(["&" + var_name + "="+value])
		
		# if an assign_value has been provided,
		# assign it instead
		if not assign_values.is_empty():
			GameState.data[var_name] = assign_values.pop_front()

func cmd_args(_cmd_arg, lines):
	await init_vars(lines, args)
	
func cmd_vars(_cmd_arg, lines):
	await init_vars(lines, [])
#endregion


#region option
# displays the unhandled options
func flush_options():
	if options.is_empty():
		return
	
	await Global.new_page()
	var option_texts = []
	for option in options:
		option_texts.push_back(option.text)
		
	var i = await Global.prompt(option_texts)
	var selected_option = options[i]
	
	options = []
	
	GameState["ans"] = selected_option.alias
	await exec_lines(selected_option.lines)

func cmd_flush(_cmd_arg, _lines):
	await flush_options()
	
# gathers an option for later
func cmd_option(cmd_arg, lines):
	var pair = cmd_arg.split("=", false, 2)
	
	var option = ActionScriptOption.new()
	option.alias = pair[0].strip_edges()
	option.text = pair[-1]
	option.lines = lines
	
	options.push_back(option)
#endregion


#region if
# executes the lines
# but restores if_state to its original afterwards
# to deal with nested ifs
func if_safe_exec_lines(lines):
	var old_if_state = if_state
	await exec_lines(lines)
	if_state = old_if_state

func cmd_if(cmd_arg, lines):
	if_state = await eval_godot(cmd_arg)
	
	if if_state == true:
		await if_safe_exec_lines(lines)
	
func cmd_else(_cmd_arg, lines):
	if if_state == false:
		await if_safe_exec_lines(lines)

func cmd_elif(cmd_arg, lines):
	if if_state == false:
		await cmd_if(cmd_arg, lines)
#endregion

func cmd_quit(_cmd_arg, _lines):
	quit = true
