extends Node
class_name Game

func _ready():
	SceneLoader.load_location("Forest", "Spawn")
	ActionScript.load("example").exec()


func _process(_delta):
	if Input.is_action_just_pressed("test"):
		Exec.add($Forest/Rock)
		await $UI/Terminal.print("Sorry, I'm freshly out of fennel.")
		await $UI/Terminal.print("My guy didn't send any this week.")
		await $UI/Terminal.print("Maybe try going to him directly?")
		await $UI/Terminal.print("He lives up north in Dominion.")
		await $UI/Terminal.new_page()
