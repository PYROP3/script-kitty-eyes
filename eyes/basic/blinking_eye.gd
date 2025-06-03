extends Node2D

@export var min_delay: float = 10.
@export var max_delay: float = 15.

var next_blink = 5.
var seed = 0
var blink_ready = false
@onready var animated_iris: AnimatedSprite2D = get_node("AnimatedIris")

func finish_blink():
	animated_iris.play("default")
	var r = rand_from_seed(seed)
	seed = r[0]
	next_blink = min_delay + (r[0] % int(max_delay - min_delay))
	
	blink_ready = true

func _process(delta: float) -> void:
	next_blink -= delta
	if next_blink <= 0. && blink_ready:
		animated_iris.play("blink")
		blink_ready = false
	
func _ready() -> void:
	animated_iris.animation_finished.connect(finish_blink)
	animated_iris.play("blink")
	animated_iris.play()
	
