extends Node

@export var swap_eyes: bool = false
@export var eye_move_factor: float = 2.
@export var eye_move_dampening: float = 0.98
@export var eye_move_lerp: float = 0.17
@export var eye_move_clamp: float = 200.
@export var test: Rect2

@onready var left_eye = get_node("LeftWindow/LEye")
@onready var left_eye_position = get_node("LeftWindow/LEye").position
@onready var right_eye = get_node("RightWindow/REye")
@onready var right_eye_position = get_node("RightWindow/REye").position

@export var initial_eye: PackedScene

@export var key_eye_map: Dictionary[Key, PackedScene]
@export var key_l_eye_map: Dictionary[Key, PackedScene]
@export var key_r_eye_map: Dictionary[Key, PackedScene]

@onready var ALL_KEYS = key_eye_map.keys() + key_l_eye_map.keys()

var last_key = null
@export var mirrored_scenes: Array[PackedScene]
@export var movable_scenes: Array[PackedScene]

@onready var ordered_keys: Array[Key] = key_eye_map.keys()
var current_index: int = 0

var current_movable: bool = false

var changed_eye: bool = false


func clear_eyes():
	for child in left_eye.get_children():
		child.queue_free()
	for child in right_eye.get_children():
		child.queue_free()
		
var eye_offset = Vector2()
var bounceback = false

func change_scene_diff(scene_l: PackedScene, scene_r: PackedScene) -> void:
	clear_eyes()
	left_eye.add_child(scene_l.instantiate())
	right_eye.add_child(scene_r.instantiate())
	right_eye.scale.x = -1.
	current_movable = (movable_scenes.find(scene_l) != -1) or (movable_scenes.find(scene_r) != -1)
	eye_offset = Vector2()

func change_scene(scene: PackedScene) -> void:
	clear_eyes()
	left_eye.add_child(scene.instantiate())
	right_eye.add_child(scene.instantiate())
	if mirrored_scenes.find(scene) == -1:
		print("mirrored!")
		right_eye.scale.x = -1.
	else:
		print("NOT mirrored!")
		right_eye.scale.x = 1.
	current_movable = movable_scenes.find(scene) != -1
	eye_offset = Vector2()

func change_scene_key(key: Key) -> void:
	print("change_scene_key:" + str(key))
	var scene = key_eye_map.get(key)
	if scene != null:
		print("change_scene_key: basic!")
		change_scene(scene)
		return

	scene = key_l_eye_map.get(key)
	if scene != null:
		print("change_scene_key: NOT basic!")
		change_scene_diff(scene, key_r_eye_map.get(key))

func _process(_delta: float) -> void:
				
	eye_offset *= eye_move_dampening
	left_eye.position = lerp(left_eye.position, left_eye_position + eye_offset, eye_move_lerp)
	left_eye.position.x = clamp(left_eye.position.x, left_eye_position.x - eye_move_clamp, left_eye_position.x + eye_move_clamp)
	left_eye.position.y = clamp(left_eye.position.y, left_eye_position.y - eye_move_clamp, left_eye_position.y + eye_move_clamp)
	right_eye.position = lerp(right_eye.position, right_eye_position + eye_offset, eye_move_lerp)
	right_eye.position.x = clamp(right_eye.position.x, right_eye_position.x - eye_move_clamp, right_eye_position.x + eye_move_clamp)
	right_eye.position.y = clamp(right_eye.position.y, right_eye_position.y - eye_move_clamp, right_eye_position.y + eye_move_clamp)
	
func handle_mouse_motion(event: InputEventMouseMotion) -> void:
	if not current_movable:
		return
		
	if event.relative == Vector2():
		return
		
	if bounceback:
		bounceback = false
		return
		
	print("mouse motion: " + str(event.relative))
	
	eye_offset += eye_move_factor * event.relative
	var _x = clamp(eye_offset.x, -eye_move_clamp, eye_move_clamp)
	var _y = clamp(eye_offset.y, -eye_move_clamp, eye_move_clamp)
	eye_offset = Vector2(_x, _y)
	
	bounceback = true
	get_viewport().warp_mouse(get_viewport().size / 2)

func _input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
		return
		
	if event is InputEventMouseMotion:
		handle_mouse_motion(event)
		return
	
	if Input.is_action_just_pressed("previous_eye"):
		current_index -= 1
		while current_index < 0:
			current_index += ordered_keys.size()
		change_scene_key(ordered_keys[current_index])
		return
		
	if Input.is_action_just_pressed("next_eye"):
		current_index += 1
		current_index %= ordered_keys.size()
		change_scene_key(ordered_keys[current_index])
		return
		
	for key in ALL_KEYS:
		if key == last_key:
			continue
		if Input.is_key_pressed(key):
			print("Key pressed: " + str(key))
			last_key = key
			change_scene_key(key)
			return

func _ready():
	if swap_eyes:
		var l_pos = left_eye.position.x
		left_eye.position.x = right_eye.position.x
		right_eye.position.x = l_pos
		
	# Enable fullscreen
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	# Hide mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)

	# Start initial eyes
	change_scene(initial_eye)
	
	print("ready!")
