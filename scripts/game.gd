extends Node
class_name Game

func _ready():
	SceneLoader.load_location("Forest", "Spawn")

func _process(_delta):
	if Input.is_action_just_pressed("test"):
		SceneLoader.load_location("Forest", "Teleport")

