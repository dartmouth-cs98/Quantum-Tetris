##### Title Scene Structure
#### VBoxContainer: Vertical Box Container, Arranges child controls vertically or horizontally,
#and rearranges the controls automatically when their minimum size changes.
### Labels
### Center Container: CenterContainer Keeps children controls centered. This container keeps all children to their minimum size, in the center.
## V box
# Start button, when pressed sends 'start' signal picked up by main 'on_title_start'
# Quit Button: when pressed quita the scene tree
# When pressed popup becomes visible. ???

extends Control

signal start


const INSTRUCTIONS = \
"""Left: %s
Right: %s
Down: %s
Drop: %s
Rotate Counter
Clockwise: %s
Rotate
Clockwise: %s
Pause: %s"""


var _inputs = ["move_left", "move_right", "move_down", "drop", "rotate_ccw",
		"rotate_cw", "cancel"]

# When the start button is pressed, emit start signal. Listened to by Main.
func _on_start_pressed():
	emit_signal("start")

# Quit the application when quit button is pressed. 
func _on_quit_pressed():
	get_tree().quit()

# Make instructions popup visible.
func _on_instructions_pressed():
	var keys = _get_input_keys()

	$instructions_popup/instructions_panel/Label.text = INSTRUCTIONS % keys
	$instructions_popup.popup()

## _get_input_keys
func _get_input_keys():
	var result = []

	for input in _inputs:
		var input_str


		# get_action_list: Returns an array of InputEvents associated with a given action.
		# InputEvent: A builtin type 
		var action_list = InputMap.get_action_list(input)
		for a in action_list:
			if input_str:
				input_str = input_str + ", " + OS.get_scancode_string(a.scancode)
			else:
				input_str = OS.get_scancode_string(a.scancode)

		result.append(input_str)

	return result
