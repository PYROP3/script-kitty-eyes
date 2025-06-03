extends Node

@export
var swap_eyes: bool = false

@onready var left_eye = get_node("LEye")
@onready var right_eye = get_node("REye")

@export var key_eye_map: Dictionary[Key, PackedScene]
var last_key = null
@export var mirrored_scenes: Array[PackedScene]

func clear_eyes():
	for child in left_eye.get_children():
		child.queue_free()
	for child in right_eye.get_children():
		child.queue_free()

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
		
	for key in key_eye_map.keys():
		if key == last_key:
			continue
		if Input.is_key_pressed(key):
			print("Key pressed: " + str(key))
			last_key = key
			var scene = key_eye_map.get(key)
			clear_eyes()
			left_eye.add_child(scene.instantiate())
			right_eye.add_child(scene.instantiate())
			if mirrored_scenes.find(scene) >= 0:
				print("mirrored!")
				right_eye.scale.x = -1.
			else:
				print("NOT mirrored!")
				right_eye.scale.x = 1.

func _ready():
	print("_ready")
	if swap_eyes:
		var l_pos = left_eye.position.x
		left_eye.position.x = right_eye.position.x
		right_eye.position.x = l_pos
		
	# Enable fullscreen
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	# Hide mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
