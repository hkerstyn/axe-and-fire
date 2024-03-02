extends Control
class_name Terminal

@export_multiline var text :String :set = set_text 

func set_text(text):
	$PanelContainer/MarginContainer/Label.text = text
