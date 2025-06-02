extends Node

@export
var swap_eyes: bool = false

@onready var left_eye = get_node("LEye")
@onready var right_eye = get_node("REye")

func _ready():
	print("_ready")
	if swap_eyes:
		var l_pos = left_eye.position.x
		left_eye.position.x = right_eye.position.x
		right_eye.position.x = l_pos
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
