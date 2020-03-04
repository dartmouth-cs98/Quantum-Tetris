extends Control

signal resume_after_text
signal tutorial_ended

var TUTORIAL_ARRAY

var t_index = 0
var text_array = ["Welcome to Quantum Tetris!\n\nIt plays just like regular Tetris,\nbut game mechanics are based on quantum principles.\n\n This tutorial will walk you through the games mechanics!! \n\n Press ENTER to continue",
"The next piece is a normal piece, and it works just like in normal tetris. \n\n You can see and change all the controls by pressing 'ESC'",
null,
"""The next piece is a Superposition piece. \n\n Superposition is a special Quantum property. 
Superposition pieces are actually two pieces at once, with a certain probability of becoming one piece or the other the moment it lands.
You can look to the Quantum visualizer for a probability reading, but you can’t know for sure which it will be until you place it down!
""", 
null,
"""Quantum computers can affect the probabilities that superposition pieces are either one piece or the other. \n\n These actions are called gates. For our game, we have X and H gates. \n\n
The first gate is the X gate. \n\n
X-Gates work by flipping the probabilities of a Superposition piece’s expected values. If the piece you want has a low probability of measuring, flip it to a high probability! \n\n

Press ‘X’ to use the power-up in game!


""",
null,
""" 
The second powerup is the H gate. \n\n
H-Gates affect the certainty of a Superposition piece. They make low probabilities high, and high probabilities low. \n\n

Use them to make a 55% chance almost certain! But be careful, because they can also turn a 99% chance back into a coin toss. \n\n

Press ‘H’ to use the power-up in game!""",
null,
"""Sometimes superposition pieces come in pairs that are Entangled.\n\n

Entanglement is another funky quantum property.  Entangled pieces are polar opposites, invisibly tethered. \n\n In this game, they mirror each other with opposite moves and rotations. \n\n
Also, the first set that hits will evaluate to their true pieces based on the probability shown in the visualizer. The second set that lands will evaluate to the opposite piece!
 """,
null,
""" Entanglement can happen when two Qubits squeeze microscopically close together.\n

They become Quantumly intertwined, which means they are now married as opposites of each other.\n

If you measure an Entangled qubit as 1, its partner is guaranteed to flip to 0 instantaneously. Two sides of the same coin.\n\n
Entangled qubits can then be separated by great distance and still affect each other.\n

In theory, this lets entangled qubits communicate faster than the speed of light!
""",
null,

"end"]


func _input(event):
#	if event.is_action_pressed("T"):
#		var new_tutorial_state = not get_tree().paused
#		get_tree().paused = new_tutorial_state
#		visible = new_tutorial_state
	if event is InputEventKey:
		print("key pressed")
		if event.scancode == KEY_ENTER:
			t_index += 1
			var next = text_array[t_index]
			print("ENTER PRESSED")
			text(next)
	
func _ready():
	var next = text_array[0]
	text(next)
	
func next_text():
	t_index += 1
	
func text(text):
	if text == null:
		emit_signal("resume_after_text")
		return
	elif text == "end":
		emit_signal("tutorial_ended")
		return
	$body.text = text
	
	
