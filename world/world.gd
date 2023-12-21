extends Node3D
var secret_tree

func _ready():
	SceneLoader.load_game_scene("forest")

func _process(_delta):
	if Input.is_action_just_pressed("test"):
		if SceneLoader.current_game_scene_name == "forest":
			SceneLoader.load_game_scene("secret_forest")
		else:
			SceneLoader.load_game_scene("forest")
