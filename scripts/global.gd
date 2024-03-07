extends Node
# singleton Global

# used for all methods and such
# that should be global
# but not in GameState

@onready var world_node = $/root/World
@onready var prompt_node = $/root/World/UI/Prompt
@onready var terminal_node = $/root/World/UI/Terminal

func prompt(options):
	return await prompt_node.prompt(options)
	
func print(text):
	return await terminal_node.print(text)

func new_page():
	return await terminal_node.new_page()
