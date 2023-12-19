extends Node3D
@onready var animation_player = $AnimationPlayer




func _ready():
	animation_player.play("0TPose")
	
func _process(_delta):
	animation_player.play("Idle", 0.0)
