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
var next_pieces = []

# The pieces currently falling
var current_pieces = []

# The "held" piece in the upper left
var held_pieces = []

# Boolean - used to prevent code from breaking if user holds down the hold-piece-command
var current_piece_held

# Stores a movement when the player holds down a key
var autoshift_action

# Boolean - false while game is paused,
# and set to true when player starts playing
var playing = false

################ Superposition Variables
var create_super_piece = true

##################### Functions ##################### 
## _ready: Randomize random number generator seeds
func _ready():
	randomize()

## new_game: Start a new game
## DONE
func new_game(level):
	# hide the title screen
	$Start.visible = false
	# generate the next piece
	next_pieces = random_piece()
	autoshift_action = ""
	$LockDelay.wait_time = 0.5
	$MidiPlayer.position = 0
	$Stats.new_game(level)
	new_piece()
	resume()
	

# The new piece gets generated
func new_piece():
	# current_piece, next_piece, etc. are all Tetromino objects
	# See res://Tetrominos/Tetromino.gd
	current_pieces = next_pieces
	for current_piece in current_pieces:
		current_piece.translation = $Matrix/Position3D.translation
	
		# Initializes the ghost-piece at the bottom
		current_piece.move_ghost()
	
	# Generates the next piece
	next_pieces = random_piece()
	
	for next_piece in next_pieces:
		next_piece.translation = $Next/Position3D.translation
	
	# THERE is a 0-magnitude 3D-vector
	for current_piece in current_pieces:
		if $Matrix/GridMap.possible_positions(current_piece.get_translations(), THERE):
			$DropTimer.start()
			current_piece_held = false
		else:
			game_over()
		
	if (current_pieces.size() > 1):
		$FakeGhost.visible = true
	else:
		$FakeGhost.visible = false

## random_piece: Generate a random piece
## IMPLEMENT FUNCTIONS FOR ACTUALLY DETERMINING SUPERPOSITION
func random_piece():
	
	
	if random_bag.size()<2:
		# Creates an array of each different piece
		# Each piece is a SCENE
		random_bag = [
			TetroI, TetroJ, TetroL, TetroO,
			TetroS, TetroT, TetroZ
		]
	var choice = randi() % random_bag.size()
	var piece = random_bag[choice].instance()
	random_bag.remove(choice)
	
	# Add first piece
	var pieces = []
	pieces.append(piece)
	add_child(piece)
	
	# create a superposition piece
	if create_super_piece:
		var second_choice = randi() % random_bag.size()
		var second_piece = random_bag[second_choice].instance()
		random_bag.remove(second_choice)
		
		pieces.append(second_piece)
		add_child(second_piece)
		
		
		############## FOR TESTING ############## 
		second_piece.set_fake()
		############## TESTING DONE ############## 
		# evaluate which piece is the superposition piece
		# call setter function to set those values
	
	
	
	# Returns the piece randomly selected from random_bag
	return pieces

# Increments the difficulty upon reaching a new level
##DONE
func new_level(level):
	if level <= 15:
		$DropTimer.wait_time = pow(0.8 - ((level-1)*0.007), level-1)
	else:
		$LockDelay.wait_time = 0.5 * pow(0.9, level-15)


# Handles all of the keyboard-inputs
# Mapping happens in res://controls.gd
##DONE
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
			for current_piece in current_pieces:
				current_piece.turn(Tetromino.CLOCKWISE)
		if event.is_action_pressed("rotate_counterclockwise"):
			for current_piece in current_pieces:
				current_piece.turn(Tetromino.COUNTERCLOCKWISE)
		if event.is_action_pressed("hold"):
			hold()
			
##DONE
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
##DONE
func _on_AutoShiftDelay_timeout():
	if autoshift_action:
		
		# Autoshift once and then start rapidly autoshifting
		process_autoshift()
		$AutoShiftTimer.start()


# Called every .03 seconds while AutoShiftTimer is running
# Rapidly autoshifts after the user has held the key down for .2 seconds
##DONE
func _on_AutoShiftTimer_timeout():
	if autoshift_action:
		process_autoshift()


# Confusingly named!
# Called to move a piece, 
# NOT just for autoshifting!
##DONE
func process_autoshift():
	for current_piece in current_pieces:
		# Move the the piece with the movement autoshift_action is currently assigned to.
		var moved = current_piece.move(movements[autoshift_action])
		
		# If the piece actually moved,
		# And 
		if moved and (autoshift_action == "soft_drop"):
			$Stats.piece_dropped(1)


# Called to instantly drop the piece to the bottom
##DONE
func hard_drop():
	
	
	
	for current_piece in current_pieces:
		var score = 0
		
		# Stats
		# (Also drops the piece until it can be dropped no more
		while current_piece.move(movements["soft_drop"]):
			score += 2
		$Stats.piece_dropped(score)
		
		
		var translations = current_piece.get_translations()
		for i in range(Tetromino.NB_MINOES):
			get_node("Matrix/DropTrail/"+str(i)).translation = translations[i]
			
		
	# This code should be executed only once
	$Matrix/DropTrail.visible = true
	$Matrix/DropTrail/Delay.start()
	$LockDelay.stop()
	lock()


# I can't find this timer.
# Maybe it was removed?
##DONE
func _on_DropTrailDelay_timeout():
	$Matrix/DropTrail.visible = false


# Moves the piece down every certain amount of time.
# Based on level!
##DONE
func _on_DropTimer_timeout():
	for current_piece in current_pieces:	
		current_piece.move(movements["soft_drop"])
	

# After the amount of time the piece can sit on the ground before being locked, check that the piece is 
#still ready to be locked.

## LOOP FUNCTION, NOT DONE
func _on_LockDelay_timeout():
	for current_piece in current_pieces:
		if not $Matrix/GridMap.possible_positions(current_piece.get_translations(), movements["soft_drop"]):
			lock()


# Transforms the piece from a falling object to a group of blocks resting on the floor
##NOT DONE
func lock():
	for current_piece in current_pieces:
		if $Matrix/GridMap.lock(current_piece):
			var t_spin = current_piece.t_spin()
			var lines_cleared = $Matrix/GridMap.clear_lines()
			$Stats.piece_locked(lines_cleared, t_spin)
			if lines_cleared or t_spin:
				$MidiPlayer.piece_locked(lines_cleared)
			remove_child(current_piece)
			
			# Spawns the next piece after this one is locked to the ground.
			new_piece()
			
		# If the piece doesn't successfully lock into the grid, game over!
		elif(playing == true):
			game_over()
		
		
# Implements holding a piece in the upper left
##DONE - but logic is tricky
func hold():
	
	# If the current piece is NOT falling
	# i.e. the current piece and the held piece are not already currently being swapped
	if not current_piece_held:
		
		# Prevents the user from using the hold command again while swapping is happening
		current_piece_held = true
		
		# Swap the falling piece and the held piece
		var swap = current_pieces
		current_pieces = held_pieces
		held_pieces = swap
		
		# Transform held_piece into falling object
		for held_piece in held_pieces:
			for mino in held_piece.minoes:
				mino.get_node("LockingMesh").visible = false
			held_piece.translation = $Hold/Position3D.translation
		
		# If we were holding a piece in the upperleft already,
		# Initialize the piece that just got swapped in
		if current_pieces.size()>0:
			for current_piece in current_pieces:
				current_piece.translation = $Matrix/Position3D.translation
				current_piece.move_ghost()
			
			# If we weren't holding a piece in the upperleft,
			# Generate a new piece!
		else:
			new_piece()
		

# Called when game is resumed after being paused
##DONE
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
	for current_piece in current_pieces:
		current_piece.visible = true
	$Ghost.visible = true
	
	# Only make the fake ghost visible if there is a second piece
	if( current_pieces.size() > 1 ): 
		$FakeGhost.visible = true
		
	if held_pieces.size()>0:
		for held_piece in held_pieces:
			held_piece.visible = true
	for next_piece in next_pieces:
		next_piece.visible = true

# Run when game gets paused
##DONE 
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
		for current_piece in current_pieces:
			current_piece.visible = false
		$Ghost.visible = false
		$FakeGhost.visible = false
		if held_pieces.size()>0:
			for held_piece in held_pieces:
				held_piece.visible = false
		for next_piece in next_pieces:
			next_piece.visible = false

# Called when the player loses
##DONE
func game_over():
	pause()
	$FlashText.print("GAME\nOVER")
	$ReplayButton.visible = true


# Called when the replay-button is pressed
##DONE
func _on_ReplayButton_pressed():
	$ReplayButton.visible = false
	for next_piece in next_pieces:
		remove_child(next_piece)
	for current_piece in current_pieces:
		remove_child(current_piece)
	if held_pieces.size()>0:
		for held_piece in held_pieces:
			remove_child(held_piece)
			held_piece = null
	$Matrix/GridMap.clear()
	pause($Start)
	
	
# Implemented in every Godot object
# See https://docs.godotengine.org/en/3.1/getting_started/workflow/best_practices/godot_notifications.html
##DONE
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_FOCUS_OUT:
			if playing:
				pause($controls_ui)


func set_current_pieces(pieces):
	
	current_pieces = pieces

func get_current_pieces():
	
	return current_pieces
