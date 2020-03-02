extends Control

var TUTORIAL_ARRAY

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_ENTER:
			text("letsgoooo")
	
func _ready():
	text("Welcome to Quantum Tetris!\n\nIt plays just like regular Tetris,\nbut game mechanics are based on quantum principles.\n\nPress ENTER to continue")

func pass_tutorial(tutorial_array):
	TUTORIAL_ARRAY = tutorial_array

func text(text):
	$body.text = text