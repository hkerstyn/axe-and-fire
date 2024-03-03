extends Control
class_name Terminal

# times writing each character
var timer :Timer

# fires when nod button is pressed/released
signal nod_just_pressed
signal nod_just_released

func _ready():
	# initialize timer
	timer = Timer.new()
	add_child(timer)
	timer.start(0.01)

func _process(_delta):
	# handle input
	if Input.is_action_just_pressed("nod"):
		nod_just_pressed.emit()
	if Input.is_action_just_released("nod"):
		nod_just_released.emit()	

# tries to find out whether 
# adding text doesnt overrun the lines
func _fits(text):
	var label_text = $Label.text
	$Label.text += text
	var does_fit = $Label.get_line_count() <= 2
	$Label.text = label_text
	return does_fit
		
# prints text down below
func print(text :String):
	if not _fits(text):
		await new_page()
	
	show()
	for char in text + " ":
		$Label.text += char 
		if Input.is_action_pressed("nod"):
			if randf() > 0.25:
				continue
		await timer.timeout

# opens a new page
# the user has to press nod first
func new_page():
	# if the page is already empty, don't do anything
	if $Label.text.is_empty():
		return
		
	# prompt the user to press nod
	$NodSymbol.show()
	await nod_just_pressed
	await nod_just_released
	$NodSymbol.hide()
	
	# clear the text
	$Label.text = ""
	
	# hide the terminal
	# the next print statement unhides it again
	hide()



