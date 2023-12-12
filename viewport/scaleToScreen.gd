extends SubViewportContainer
# sets the scale such that it nicely centers on the screen
# making an aspect ratio of 16:9


func _ready():
	pass

func _process(delta):
	# the screen_size of the screen
	var screen_size = get_viewport_rect().size
	
	# now figure out the game size
	var game_size = Vector2.ZERO
	# try fitting it horizontally
	game_size.x = screen_size.x
	# now use 16:9 aspect ratio
	game_size.y = 9.0 / 16.0 * game_size.x
	
	# put it in the middle vertically
	position = Vector2(0.0, (screen_size.y - game_size.y)*0.5)
	
	# check if that fits inside the screen
	if game_size.y > screen_size.y:
		# if not, do a vertical fit instead
		game_size.y = screen_size.y
		game_size.x = 16.0/9.0 * game_size.y
		
		# put it in the middle horizontally
		position = Vector2((screen_size.x - game_size.x)*0.5, 0.0)
	
	# now scale our viewport up to fit that size
	scale.x = game_size.x / 192.0
	scale.y = game_size.y / 108.0
	
	
