extends SubViewportContainer
@export var pixel_size : Vector2

func _ready():
	# set our size and the sub viewport's size
	# to the specified pixel size   
	$Viewport.size = pixel_size
	size = pixel_size
	
	# set the texture filter to nearest
	# this makes sure the pixelization is crisp
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

# changes position and scale
# such that this element is always in the center,
# is as big as possible
# and retains its aspect ratio
func _process(_delta):
	# the screen_size of the screen
	var screen_size = get_viewport_rect().size
	
	# scale this element to screen size
	scale = screen_size / size
	
	# make the scale uniform
	scale = min(scale.x, scale.y) * Vector2.ONE
	
	# move it such that it is in the center
	position = (screen_size - scale*size)*0.5

	
	
