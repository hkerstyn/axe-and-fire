extends Node
class_name Game

func _ready():
	SceneLoader.load_location("Forest", "Spawn")
	Exec.add(Global.find("Elaine1")).set_action_script("example")

func _process(_delta):
	if Input.is_action_just_pressed("test"):
		Global.find("SpeechThingy").set_origin(Global.find("Elaine1"))
