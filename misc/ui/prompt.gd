class_name Prompt
extends Control

const corner = Vector2(192, 108)
const left_up_margin = Vector2(2, 2)
const right_down_margin = Vector2(1, 0)
const spacing = 1
const cursor = ">"

var selected_i :int
var n :int

@onready var options_node := $Options
@onready var background_node := $Background
@onready var selector_node := $Selector

signal select

func init_sizes(options_text):
	options_node.text = options_text
	options_node.reset_size()
	options_node.position = corner - options_node.size - right_down_margin
	
	selector_node.text = cursor
	selector_node.reset_size()
	selector_node.position = options_node.position + Vector2.LEFT * (spacing + selector_node.size.x)
	
	background_node.position = selector_node.position - left_up_margin
	background_node.size = corner - background_node.position

# displays the options on the screen
# and returns the index of the one the player chose
func prompt(options:Array):
	show()
	var options_text = ""
	for option in options:
		options_text += option + "\n" 
	init_sizes(options_text)
	
	selected_i = 0
	n = options.size()
	
	await select
	hide()
	return selected_i

func select_i(i :int):
	selected_i = i
	var selector_text = ""
	for _i in range(i):
		selector_text += "\n"
	selector_text += cursor
	selector_node.text = selector_text

func _process(_delta):
	if not is_visible_in_tree():
		return
	if Input.is_action_just_pressed("up"):
		select_i(posmod(selected_i - 1, n))
		
	if Input.is_action_just_pressed("down"):
		select_i(posmod(selected_i + 1, n))
		
	if Input.is_action_just_pressed("use"):
		select.emit()
