extends Node
# singleton World

var world_path = "/root/Node2D/PixelizerViewportContainer/PixelizerViewport/World"
@onready var world = get_node(world_path)

func _ready():
	SceneLoader.load_game_scene("forest", "Spawn")

func _process(delta):
	if Input.is_action_just_pressed("test"):
		SceneLoader.load_game_scene("forest", "Teleport")

