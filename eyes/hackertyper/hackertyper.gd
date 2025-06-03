extends Node2D

@onready var textbox: RichTextLabel = get_node("Text")
var used_text = ""
var text = ""
var seed = 0
var delay = 0.

const APPEND_DELAY = .02

func load_text_file(file_path: String) -> String:
	var file = FileAccess.open(file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	return content
	
func _ready() -> void:
	text = load_text_file("res://eyes/hackertyper/kernel.txt")
	textbox.pop_all()
	textbox.push_mono()
	
func _process(delta: float) -> void:
	delay -= delta
	if delay > 0:
		return
		
	var a = rand_from_seed(seed)
	var n_chars = 1 + a[0] % min(5, text.length())
	seed = a[0]
	
	var append = text.substr(0, n_chars)
	#textbox.append_text("[code]" + append + "[/code]")
	textbox.append_text(append)
	used_text += append
	text = text.substr(n_chars)
	delay = APPEND_DELAY
	
	if text.length() == 0:
		text = used_text
		used_text = ""
