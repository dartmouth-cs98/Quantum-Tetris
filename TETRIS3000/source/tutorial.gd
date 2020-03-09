extends Control

signal resume_after_text
signal tutorial_ended
signal start_backlist

var running = false

var t_index = 0
var text_array = ["Welcome to Quantum Tetris!\n\nIt plays just like regular Tetris,\nbut game mechanics are based on quantum principles.\n\n This tutorial will walk you through the games mechanics!! \n\n Press ENTER to continue",
"""The next piece is a normal piece, and it works just like in normal tetris. \n Drop the piece to move to the next screen using the down arrow or the space bar! \n\n
You can pause the tutorial and see this text again by pressing 'ESC'. If you have paused the tutorial, press 'ESC' to see the piece again""",
null,
"""The next piece is a Superposition piece. \n\n Superposition is a special Quantum property. 
Superposition pieces are actually two pieces at once, with a certain probability of becoming one piece or the other the moment it lands.
You can look to the Quantum visualizer for a probability reading, but you cannot know for sure which it will be until you place it down!
\n\n Press 'ENTER' and drop the piece to move to the next screen. Press 'ESC' to pause or resume the tutorial. 
""", 
null,
"""Quantum computers can affect the probabilities that superposition pieces are either one piece or the other. \n\n These actions are called gates. For our game, we have X and H gates. \n
The first gate is the X gate. \n
X-Gates work by flipping the probabilities of a Superposition piece’s expected values. If the piece you want has a low probability of measuring, flip it to a high probability! \n
Press ‘X’ to use the power-up in game!
\n\n Press 'ENTER' and drop the piece to move to the next screen. Press 'ESC' to pause or resume the tutorial. 
""",
null,
""" 
The second powerup is the H gate. H-Gates affect the certainty of a Superposition piece. They make low probabilities high, and high probabilities low. \n
Use them to make a 55% chance almost certain! But be careful, because they can also turn a 99% chance back into a coin toss. \n
Press ‘H’ to use the power-up in game!
You can only use one power-up per piece, so choose wisely!
\n\n Press 'ENTER' and drop the piece to move to the next screen. Press 'ESC' to pause or resume the tutorial. 
""",
null,
"""Sometimes superposition pieces come in pairs that are Entangled.\n

Entanglement is another funky quantum property.  Entangled pieces are polar opposites, invisibly tethered. \n In this game, they mirror each other with opposite moves and rotations. \n
Also, the first set that hits will evaluate to their true pieces based on the probability shown in the visualizer. The second set that lands will evaluate to the opposite piece!
\n\n Press 'ENTER' and drop the piece to move to the next screen. Press 'ESC' to pause or resume the tutorial. 
 """,
"start_backlist",
""" Entanglement can happen when two Qubits squeeze microscopically close together.  They become Quantumly intertwined, which means they are now married as opposites of each other.\n
If you measure an Entangled qubit as 1, its partner is guaranteed to flip to 0 instantaneously. Two sides of the same coin.\n
Entangled qubits can then be separated by great distance and still affect each other.  In theory, this lets entangled qubits communicate faster than the speed of light!
\n\n Press 'ENTER' and drop the piece to move to the next screen. Press 'ESC' to pause or resume the tutorial. 
""",
null,
"""
X and H gates can also be used on entanglement pieces to affect the probabilities for the first piece that lands! Try using one of them now!
\n\n Press 'ENTER' and drop the piece to move to the next screen. Press 'ESC' to pause or resume the tutorial. 
""",
null,
"""From now on, you can see and change all the controls by pressing 'ESC'. \n\n This is the end of the tutorial! Goodluck and have fun!!""",
"end"]


func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_ENTER and event.pressed and running:
			t_index += 1
			var next = text_array[t_index]
			text(next)
	
func start_tutorial():
	running = true

func _ready():
	var next = text_array[0]
	text(next)
	
func next_text():
	t_index += 1
	text(text_array[t_index])
	running = true
	
func text(text):
	if text == null:
		emit_signal("resume_after_text")
		running = false 
	elif text == "end":
		emit_signal("tutorial_ended")
		t_index = 0
		running = false 
	elif text == "start_backlist":
		emit_signal("start_backlist")
		emit_signal("resume_after_text")
		running = false 
	else:
		$body.text = text
	
	
