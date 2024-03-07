extends Node
# singleton Global

# used for all methods and such
# that should be global
# but not in GameState

@onready var world_node = $/root/World

func prompt(options):
	return await find("Prompt").prompt(options)
	
func print(text):
	return await find("Terminal").print(text)

func new_page():
	return await find("Terminal").new_page()

func find(node_name):
	return world_node.find_child(node_name, true, false)
	
func name(text):
	var words = Array(text.to_snake_case().split("_"))
	return " ".join(words.map(func(word): return word.to_pascal_case()))

func set_speech_origin(origin):
	find("SpeechThingy").set_origin(find(origin))
