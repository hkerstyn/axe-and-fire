extends Node
class_name Game

func _ready():
	SceneLoader.load_location("Forest", "Spawn")
	Exec.add(Global.find("Elaine1")).set_action_script("example")
