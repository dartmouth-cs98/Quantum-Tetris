extends Control

signal resume_after_text

var TUTORIAL_ARRAY

var t_index = 0
var text_array = ["Welcome to Quantum Tetris!\n\nIt plays just like regular Tetris,\nbut game mechanics are based on quantum principles.\n\n This tutorial will walk you through the games mechanics!! \n\n Press ENTER to continue",
"The next piece is a normal piece, and it works just like in normal tetris. \n\n You can see all the controls for a piece by pressing " + String(InputMap.get_action_list("pause")),
null,
"""The next piece is a Superposition piece. \n\n Superposition is a special Quantum property. 
Superposition pieces are actually two pieces at once, with a certain probability of becoming one piece or the other the moment it lands.
You can look to the Quantum visualizer for a probability reading, but you can’t know for sure which it will be until you place it down!
""", 
null,
"The"]


func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_ENTER:
			t_index += 1
			var next = text_array[t_index]
			text(next)
	
func _ready():
	var next = text_array[0]
	text(next)

func pass_tutorial(tutorial_array):
	TUTORIAL_ARRAY = tutorial_array

func next_text():
	t_index += 1

func text(text):
	if text == null:
		emit_signal("resume_after_text")
		return
	$body.text = text
	
