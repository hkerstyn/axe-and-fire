extends Node
class_name Game

func _ready():
	SceneLoader.load_location("Forest", "Spawn")
	spam()

func spam():
	while true:
		await $UI/Terminal.print("Hi, this is a test")
