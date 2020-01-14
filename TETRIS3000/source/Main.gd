extends WorldEnvironment

##################### Preload Scripts ##################### 
const Tetromino = preload("res://Tetrominos/Tetromino.gd")
const TetroI = preload("res://Tetrominos/TetroI.tscn")
const TetroJ = preload("res://Tetrominos/TetroJ.tscn")
const TetroL = preload("res://Tetrominos/TetroL.tscn")
const TetroO = preload("res://Tetrominos/TetroO.tscn")
const TetroS = preload("res://Tetrominos/TetroS.tscn")
const TetroT = preload("res://Tetrominos/TetroT.tscn")
const TetroZ = preload("res://Tetrominos/TetroZ.tscn")


##################### Constants and Varibles ##################### 
const THERE = Vector3(0, 0, 0)

#three directions
const movements = {
	"move_right": Vector3(1, 0, 0),
	"move_left": Vector3(-1, 0, 0),
	"soft_drop": Vector3(0, -1, 0)
}

var random_bag = []

# The next piece queued in the upper right
var next_piece

# The piece currently falling
var current_piece

# The "held" piece in the upper left
var held_piece

# Boolean
var current_piece_held
var autoshift_action

var playing = false

################ Superposition Variables
var create_super_piece = false

##################### Functions ##################### 
## _ready: Randomize random number generator seeds
func _ready():
	randomize()

## new_game: Start a new game
func new_game(level):
	# hide the title screen
	$Start.visible = false
	# generate the next piece
	next_piece = random_piece()
	autoshift_action = ""
	$LockDelay.wait_time = 0.5
	$MidiPlayer.position = 0
	$Stats.new_game(level)
	new_piece()
	resume()
	
func new_piece():
	# current_piece, next_piece, etc. are all Tetromino objects
	# See res://Tetrominos/Tetromino.gd
	current_piece = next_piece
	current_piece.translation = $Matrix/Position3D.translation
	
	# Initializes the ghost-piece at the bottom
	current_piece.move_ghost()
	
	# Generates the next piece
	next_piece = random_piece()
	next_piece.translation = $Next/Position3D.translation
	
	# THERE is a 0-magnitude 3D-vector
	if $Matrix/GridMap.possible_positions(current_piece.get_translations(), THERE):
		$DropTimer.start()
		current_piece_held = false
	else:
		game_over()

## random_piece: Generate a random piece
func random_piece():
	
	if not random_bag:
		# Creates an array of each different piece
		# Each piece is a SCENE
		random_bag = [
			TetroI, TetroJ, TetroL, TetroO,
			TetroS, TetroT, TetroZ
		]
	var choice = randi() % random_bag.size()
	var piece = random_bag[choice].instance()
	random_bag.remove(choice)
	if create_super_piece:
		pass #var second_piece = 
	add_child(piece)
	
	# Returns the piece randomly selected from random_bag
	return piece

# Increments the difficulty upon reaching a new level
func new_level(level):
	if level <= 15:
		$DropTimer.wait_time = pow(0.8 - ((level-1)*0.007), level-1)
	else:
		$LockDelay.wait_time = 0.5 * pow(0.9, level-15)


# Handles all of the keyboard-inputs
# Mapping happens in res://controls.gd
func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		if playing:
			pause($controls_ui)
		else:
			resume()
	if event.is_action_pressed("toggle_fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen
	if playing:
		
		# When the key of the current autoshift_action is released,
		if autoshift_action and event.is_action_released(autoshift_action):
			$AutoShiftDelay.stop()
			$AutoShiftTimer.stop()
			autoshift_action = ""
			process_new_action(Input)
		else:
			process_new_action(event)
		if event.is_action_pressed("hard_drop"):
			hard_drop()
		if event.is_action_pressed("rotate_clockwise"):
			current_piece.turn(Tetromino.CLOCKWISE)
		if event.is_action_pressed("rotate_counterclockwise"):
			current_piece.turn(Tetromino.COUNTERCLOCKWISE)
		if event.is_action_pressed("hold"):
			hold()
			
func process_new_action(event):
	
	# movements are the 3 possible ways to move a piece
	# represented each as a single 3D-vector
	# (left, right, and soft-drop)
	for action in movements:
		
		# When the user starts holding down a new key,
		# For that key,
		if action != autoshift_action and event.is_action_pressed(action):
			
			# Stop autoshifting!
			$AutoShiftTimer.stop()
			
			# Switch to the new key the user is holding down
			autoshift_action = action
			
			# Shift
			# This is NOT actually an autoshift!
			# This is the user moving the piece a single time
			process_autoshift()
			
			# Give the user .2 seconds to release the key before autoshifting starts
			$AutoShiftDelay.start()
			break

# Called every .2 seconds while AutoShiftDelay is running
func _on_AutoShiftDelay_timeout():
	if autoshift_action:
		
		# Autoshift once and then start rapidly autoshifting
		process_autoshift()
		$AutoShiftTimer.start()


# Called every .03 seconds while AutoShiftTimer is running
# Rapidly autoshifts after the user has held the key down for .2 seconds
func _on_AutoShiftTimer_timeout():
	if autoshift_action:
		process_autoshift()


# Confusingly named!
# Called to move a piece, 
# NOT just for autoshifting!
func process_autoshift():
	
	# Move the the piece with the movement autoshift_action is currently assigned to.
	var moved = current_piece.move(movements[autoshift_action])
	
	# If the piece actually moved,
	# And 
	if moved and (autoshift_action == "soft_drop"):
		$Stats.piece_dropped(1)


# Called to instantly drop the piece to the bottom
func hard_drop():
	var score = 0
	while current_piece.move(movements["soft_drop"]):
		score += 2
	$Stats.piece_dropped(score)
	var translations = current_piece.get_translations()
	for i in range(Tetromino.NB_MINOES):
		get_node("Matrix/DropTrail/"+str(i)).translation = translations[i]
	$Matrix/DropTrail.visible = true
	$Matrix/DropTrail/Delay.start()
	$LockDelay.stop()
	lock()

func _on_DropTrailDelay_timeout():
	$Matrix/DropTrail.visible = false

func _on_DropTimer_timeout():
	current_piece.move(movements["soft_drop"])
	
func _on_LockDelay_timeout():
	if not $Matrix/GridMap.possible_positions(current_piece.get_translations(), movements["soft_drop"]):
		lock()

func lock():
	if $Matrix/GridMap.lock(current_piece):
		var t_spin = current_piece.t_spin()
		var lines_cleared = $Matrix/GridMap.clear_lines()
		$Stats.piece_locked(lines_cleared, t_spin)
		if lines_cleared or t_spin:
			$MidiPlayer.piece_locked(lines_cleared)
		remove_child(current_piece)
		new_piece()
	else:
		game_over()

func hold():
	if not current_piece_held:
		current_piece_held = true
		var swap = current_piece
		current_piece = held_piece
		held_piece = swap
		for mino in held_piece.minoes:
			mino.get_node("LockingMesh").visible = false
		held_piece.translation = $Hold/Position3D.translation
		if current_piece:
			current_piece.translation = $Matrix/Position3D.translation
			current_piece.move_ghost()
		else:
			new_piece()
		
func resume():
	playing = true
	$DropTimer.start()
	$Stats.time = OS.get_system_time_secs() - $Stats.time
	$Stats/Clock.start()
	$MidiPlayer.resume()
	$controls_ui.visible = false
	$Stats.visible = true
	$Matrix.visible = true
	$Matrix/GridMap.visible = true
	$Hold.visible = true
	$Next.visible = true
	current_piece.visible = true
	$Ghost.visible = true
	if held_piece:
		held_piece.visible = true
	next_piece.visible = true

# Run when game gets paused
func pause(gui=null):
	playing = false
	$MidiPlayer.stop()
	$DropTimer.stop()
	$LockDelay.stop()
	$AutoShiftDelay.stop()
	$AutoShiftTimer.stop()
	$Stats/Clock.stop()
	$Stats.time = OS.get_system_time_secs() - $Stats.time
	if gui:
		gui.visible = true
		$Stats.visible = false
		$Matrix.visible = false
		$Matrix/GridMap.visible = false
		$Hold.visible = false
		$Next.visible = false
		current_piece.visible = false
		$Ghost.visible = false
		if held_piece:
			held_piece.visible = false
		next_piece.visible = false

func game_over():
	pause()
	$FlashText.print("GAME\nOVER")
	$ReplayButton.visible = true

func _on_ReplayButton_pressed():
	$ReplayButton.visible = false
	remove_child(next_piece)
	remove_child(current_piece)
	if held_piece:
		remove_child(held_piece)
		held_piece = null
	$Matrix/GridMap.clear()
	pause($Start)
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_FOCUS_OUT:
			if playing:
				pause($controls_ui)
