extends Node2D

@export var rainbow: bool
@export_range(-2, 2) var animate_speed: float
@export_range(60, 80) var min_db: float

const VU_COUNT = 20
#const FREQ_MAX = 11050.0
const FREQ_MIN = 32.
const FREQ_MAX = 8192.

const FREQ_K = pow(FREQ_MAX/FREQ_MIN, 1./float(VU_COUNT))

# TODO implement pixelization
const PIXELIZATION_FACTOR = 15

#const WIDTH = 400
const HEIGHT = 250
const HEIGHT_MIN = 50
const HEIGHT_SCALE = 8.0
#const MIN_DB = 40
const ANIMATION_SPEED = 0.1

const VU_SPACING = TAU/60.

const N_RINGS = 5

var spectrum
var effect
var min_values = []
var max_values = []
var last_delta = 0.

func bar_color(i: int, h: float, d: float):
	if rainbow:
		if animate_speed != 0.:
			return Color.from_hsv(float(i) / float(VU_COUNT) + d, 1., 1.)
		return Color.from_hsv(float(i) / float(VU_COUNT), 1., 1.)
	return lerp(Color.AQUA, Color.AQUAMARINE, clampf(h*4./HEIGHT, 0., 1.))
	
func _draw():
	for i in range(VU_COUNT):
		var min_height = min_values[i]
		var max_height = max_values[i]
		var height = lerp(min_height, max_height, ANIMATION_SPEED)
		
		draw_arc(
			Vector2(0., 0.),
			HEIGHT_MIN+height/2.,
			(i*TAU/VU_COUNT-PI/2.)/2.,
			((i+1)*TAU/VU_COUNT-VU_SPACING-PI/2.)/2.,
			5,
			#Color.from_hsv(float(VU_COUNT * 0.6 + i * 0.5) / VU_COUNT, 0.5, 1.0),
			#Color.AQUA,
			#lerp(Color.AQUA, Color.AQUAMARINE, clampf(height*4/HEIGHT, 0., 1.)),
			bar_color(i, height, last_delta),
			HEIGHT_MIN+height
			)
		
		draw_arc(
			Vector2(0., 0.),
			HEIGHT_MIN+height/2.,
			(i*TAU/VU_COUNT-PI/2.)/2.+PI,
			((i+1)*TAU/VU_COUNT-VU_SPACING-PI/2.)/2.+PI,
			5,
			#Color.from_hsv(float(VU_COUNT * 0.6 + i * 0.5) / VU_COUNT, 0.5, 1.0),
			#Color.AQUA,
			#lerp(Color.AQUA, Color.AQUAMARINE, clampf(height*4/HEIGHT, 0., 1.)),
			bar_color(i, height, last_delta),
			HEIGHT_MIN+height
			)
	
	draw_circle(
		Vector2(),
		HEIGHT_MIN,
		Color.BLACK)
		
	for i in range(N_RINGS):
		draw_arc(
			Vector2(0., 0.),
			HEIGHT_MIN + (i + 1) * HEIGHT / (2 * N_RINGS),
			0.,
			TAU,
			5*VU_COUNT,
			Color.BLACK,
			5.
			)

func _process(delta):
	var data = []
	var prev_hz = FREQ_MIN
	var avg_energy = 0.
	
	for i in range(1, VU_COUNT + 1):
		var magnitude = spectrum.get_magnitude_for_frequency_range(prev_hz, prev_hz*FREQ_K).length()
		var energy = clampf((min_db + linear_to_db(magnitude)) / min_db, 0, 1)
		avg_energy += energy / VU_COUNT
		var height = energy * HEIGHT * HEIGHT_SCALE
		data.append(height)
		prev_hz = prev_hz*FREQ_K

	for i in range(VU_COUNT):
		if data[i] > max_values[i]:
			max_values[i] = data[i]
		else:
			max_values[i] = lerp(max_values[i], data[i], ANIMATION_SPEED)

		if data[i] <= 0.0:
			min_values[i] = lerp(min_values[i], 0.0, ANIMATION_SPEED)

	last_delta += delta * animate_speed * lerpf(-.3, -3., avg_energy)
	last_delta -= floorf(last_delta)
	
	# Sound plays back continuously, so the graph needs to be updated every frame.
	queue_redraw()

#func _exit_tree() -> void:
	#effect.set_recording_active(false)

func _ready():
	var idx = AudioServer.get_bus_index("Master")
	#effect = AudioServer.get_bus_effect(idx, 0)
	spectrum = AudioServer.get_bus_effect_instance(idx, 1)
	min_values.resize(VU_COUNT)
	max_values.resize(VU_COUNT)
	min_values.fill(0.0)
	max_values.fill(0.0)
	#effect.set_recording_active(true)
	#print("Is recording active: " + str(effect.is_recording_active()))
