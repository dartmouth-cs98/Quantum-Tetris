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

const piece_scene_to_int= {
	TetroI: 0,
	TetroJ: 1,
	TetroL: 2,
	TetroO: 3,
	TetroS: 4,
 	TetroT: 5,
	TetroZ: 6
}

var random_bag = []

## Arrays to Hold Pieces
var backlist = []
var next_pieces = []
var current_pieces = []
var held_pieces = []

# Probabilities
var probabilities_backlist = []
var probabilities = [0,0,0,0]

## Powerups
# List of lists of floats (probabilities - for display)
var h_backlist = []
var x_backlist = []
# List of lists of bools - true if fake and false if real
var h_backlist_eval = []
var x_backlist_eval = []
# Object names to hold place in list
var x_probabilities = []
var h_probabilities = []
var x_evals = []
var h_evals = []
# Variables to limit powerup usage
var h_use = false
var x_use = false

# Boolean - used to prevent code from breaking if user holds down the hold-piece-command
var current_piece_held

# Stores a movement when the player holds down a key
var autoshift_action

# Boolean - false while game is paused,
# and set to true when player starts playing
var playing = false


## Creating Pieces
var running = false
var powerups_running = false

## For MultiThreading
var backlist_thread
var powerup_thread
var mutex
var powerup_mutex

## For requests
var current_names = []
var next_names = []

## idk
var turns = 5

## From response for create piece
#var types = [0,0,0,0]

## For responce
var entangled_pieces = false
var init_entangled_pieces = false

##Signals
signal super_response_received
signal h_response_received
signal x_response_received
signal h_eval_response_received
signal x_eval_response_received
signal init_eval_response_received
signal have_pieces
signal start_thread

var num_H_gates: int = 0
var num_X_gates: int = 0

##################### Functions ##################### 
## _ready: Randomize random number generator seeds
func _ready():
	randomize()
	running = true
	powerups_running = true
	mutex = Mutex.new()
	powerup_mutex = Mutex.new()
	backlist_thread = Thread.new()
	backlist_thread.start(self,"handle_backlist")
	


##################### Handle Piece Backlist
func handle_backlist(userdata):
	var num_turns = 20
	var total_pieces = backlist.size()
	for i in range(num_turns - total_pieces):
		#print("TESTING, backlist.size = " + String(backlist.size()))
		var turn_type = count_turns()
		# Superposition
		if(turn_type == 1):
#			print("TESTING, 1-Handle_Backlist, adding superposition to backlist")
			# Get Pieces
			random_piece(true, false)
			yield(self, "have_pieces")
			
			powerup_thread = Thread.new()
			powerup_thread.start(self,"handle_powerups_backlist", backlist.back())
#			print("TESTING, 8-Handle_Backlist, have pieces, calling evaluate") 
			# Determine which pieces are fake
			_initial_evaluate_superposition()
			yield(self, "init_eval_response_received")
			#move data over to here 
#			print("TESTING, 11-Handle_Backlist, done adding super piece") 
		# Superposition and Entanglement
		elif(turn_type == 2):
#			print("TESTING, 1-Handle_Backlist, adding entanglement to backlist")
			random_piece(true, true)
			yield(self, "have_pieces")

			powerup_thread = Thread.new()
			powerup_thread.start(self,"handle_powerups_backlist", backlist.back())
			# Determine which pieces are fake
#			print("TESTING, 8-Handle_Backlist, have pieces, calling evaluate") 
			_initial_evaluate_superposition()
			yield(self, "init_eval_response_received")
			init_entangled_pieces = true
#			print("TESTING, 11-Handle_Backlist, have pieces, calling evaluate") 
			_initial_evaluate_superposition()
			yield(self, "init_eval_response_received")
#			print("TESTING, 14-Handle_Backlist, done adding entangled pieces") 
		else:
			random_piece(false, false)
#			print("TESTING, 1-Handle_Backlist, adding normal to backlist")
		#print("TESTING, i = " + String(i) + "  num_turns-total pieces = " + String(num_turns - total_pieces -1))
	running = false


func count_turns():
	turns -= 1
#	print("TESTING - ALT - TURNS init: " + String(turns))
	if turns == 0:
		var coin = randi()%11+1
		turns = randi()%4 + 1
#		print("TESTING - ALT - TURNS after 0: " + String(turns))
		if (coin)>7:
			return(2)
		else:
			return(1)
	else:
		return(0)
	
func random_piece( create_super_piece, create_entanglement):
	# Add first piece
	var pieces = []
	var probs=[0,0,0,0]

	if (create_super_piece): 
#		print("TESTING, 2-Random_Piece, creating first entanglement pieces and calling request")
		
		## GET FIRST PIECES
		# Call superposition request, which gets piece probabilities and types
		_superposition_request()
		
		
		# Wait till http request node received a server responce
		var state = yield(self, "super_response_received")
	
		var types = state["type"]
		probs = state["prob"]
		
#		print("TESTING, 5-Random_Piece, back in Random_Piece")
		# instantiate the piece returned by server
		var piece0 = return_name(types[0]).instance()
		# add it to pieces list
		pieces.append(piece0)
		# add piece to the game board
		add_child(piece0)
		piece0.visible = false
		
		var piece1 = return_name(types[1]).instance()
		pieces.append(piece1)
		add_child(piece1)
		piece1.visible = false
		
		if(create_entanglement):
#			print("TESTING, 2-Random_Piece, creating second entanglement pieces and calling request")
		# Repeat for pieces 2 and 3 (during entanglement)
			_superposition_request()
			
					# Wait till http request node received a server responce
			var state_entangled = yield(self, "super_response_received")
			var types_entangled = state_entangled["type"]
			var probs_entangled = state_entangled["prob"]
			
			for entangled_prob in probs_entangled:
				probs.append(entangled_prob)
#			print("TESTING, 5-Random_Piece, back in Random_Piece")
			var piece2 = return_name(types_entangled[0]).instance()
			pieces.append(piece2)
			add_child(piece2)
			piece2.visible = false
			
			var piece3 = return_name(types_entangled[1]).instance()
			pieces.append(piece3)
			add_child(piece3)
			piece3.visible = false
			
	
			
			pieces[0].entangle(-1)
			pieces[1].entangle(-1)
			pieces[2].entangle(1)
			pieces[3].entangle(1)
		#	print("TESTING, 6-Random_Piece, result: " + String(pieces))
		else:
			pieces[0].entangle(0)
			pieces[1].entangle(0)
			
			probs.append(0)
			probs.append(0)
	
#		print("TESTING, 6-Random_Piece, result: " + String(pieces))
		
	else:
		if random_bag.size()<5:
			# Creates an array of each different piece
			# Each piece is a SCENE
			random_bag = [
				TetroI, TetroJ, TetroL, TetroO,
				TetroS, TetroT, TetroZ
			]
		var choice = randi() % random_bag.size()
		var piece = random_bag[choice].instance()
		random_bag.remove(choice)
		piece.entangle(0)
		pieces.append(piece)
		add_child(piece)
		piece.visible = false
	
	# Add pieces to backlist, emit completed signal, and exit
	mutex.lock()
	backlist.append(pieces)
	probabilities_backlist.append(probs)
	mutex.unlock()
	
	powerup_mutex.lock()
	h_backlist.append([0,0,0,0])
	x_backlist.append([0,0,0,0])
	h_backlist_eval.append([true, false, true, false])
	x_backlist_eval.append([true, false, true, false])
	powerup_mutex.unlock()
			
#	print("TESTING, 7-Random_Piece, added pieces to backlist")
	emit_signal("have_pieces")
	
func return_name(i):
	for key in piece_scene_to_int.keys():
		if piece_scene_to_int[key] == i:
			return key
			
func abort():
	print("abort!")
	var pieces = []
	if random_bag.size()<5:
			# Creates an array of each different piece
			# Each piece is a SCENE
			random_bag = [
				TetroI, TetroJ, TetroL, TetroO,
				TetroS, TetroT, TetroZ
			]
	var choice = randi() % random_bag.size()
	var piece = random_bag[choice].instance()
	random_bag.remove(choice)
	piece.entangle(0)
	pieces.append(piece)
	add_child(piece)
	piece.visible = false
	
	backlist.append(pieces)
	probabilities_backlist.append([0,0,0,0])
	h_backlist.append([0,0,0,0])
	x_backlist.append([0,0,0,0])
	h_backlist_eval.append([true, false, true, false])
	x_backlist_eval.append([true, false, true, false])
	
##################### Handle Powerup Backlist
func handle_powerups_backlist(userdata):
	print("TESTING: Another handle_powerups")
#	yield(self, "start_thread")
	
	var pieces = userdata
	######  Kinda dont need this anymore
	var h_size = h_backlist.size()
	var test_size = x_backlist.size()
	
	if h_size != test_size:
		print("ERROR, x and h powerup lists do not match")
	######  To here
	else:
		# Only cover indices that haven't been covered
		#print("TESTING, handle_powerups_backlist, backlist size = "+ String(backlist.size()))

		#for pieces in backlist: #range(backlist.size()):
		#print("TESTING, handle_powerups_backlist, index = "+ String(index))
		# Wait change to objects
		#if index>backlist.size():
		#	break
		#var pieces = backlist[index]
		#var piece_probs = probabilities_backlist[index]
		mutex.lock()
		var piece_probs = probabilities_backlist[backlist.find(pieces)]
		mutex.unlock()
			
#		print("TESTING, handle_powerups_backlist, pieces = "+ String(pieces))
		if pieces.size()>1:
			## THREADING HERE
			yield(self.apply_H([piece_probs, false, pieces]), "completed")
			yield(self.apply_X([piece_probs, false, pieces]), "completed")
			if pieces.size()>2:
				yield(self.apply_H([piece_probs, true, pieces]), "completed")
				yield(self.apply_X([piece_probs, true, pieces]), "completed")

	powerups_running = false
	
func apply_H(userdata):
	
	#print("TESTING, apply H (1), in apply h")
	var probability_list = userdata[0]
	var entangle = userdata[1]
	var pieces = userdata[2]
	#print("TESTING, apply H (2), entangle is " + String(entangle))
	
	if !entangle:
		_H_gate_request([probability_list[0], probability_list[1]])
	else:
		_H_gate_request([probability_list[2], probability_list[3]])
		
	var state = yield(self,  "h_response_received")
	#print("TESTING, apply H (3), state = " + String(state) + " entangle is "+ String(entangle))
	powerup_mutex.lock()
	if !entangle:
		h_backlist[backlist.find(pieces)][0] = state[0]
		h_backlist[backlist.find(pieces)][1] = state[1]
	
	else:
		h_backlist[backlist.find(pieces)][2] = state[0]
		h_backlist[backlist.find(pieces)][3] = state[1]
	powerup_mutex.unlock()
		
	#print("TESTING, apply_H (4), entangle is " + String(entangle) + " h_backlist is " +  String(h_backlist[h_backlist.size()-1]))
		
	_evaluate_superposition(state, "hgate")
	var eval_state = yield(self, "h_eval_response_received")
	#print("TESTING, apply H (5), eval_state = " + String(eval_state) + " entangle is "+ String(entangle))
	powerup_mutex.lock()
	if !entangle:
		h_backlist_eval[backlist.find(pieces)][0] = (eval_state[0])
		h_backlist_eval[backlist.find(pieces)][1] = (eval_state[1])
	else:
		h_backlist_eval[backlist.find(pieces)][2] = (eval_state[0])
		h_backlist_eval[backlist.find(pieces)][3] = (eval_state[1])
	powerup_mutex.unlock()
	#print("TESTING, apply_H (6), entangle is " + String(entangle) + " h_eval_backlist is " + String(h_backlist_eval[h_backlist_eval.size()-1]))
		
func apply_X(userdata):
	
	#print("TESTING, apply_X (1), in apply X")
	var probability_list = userdata[0]
	var entangle = userdata[1]
	var pieces = userdata[2]
	#print("TESTING, apply_X (2), entangle is " + String(entangle))
	
	if !entangle:
		_X_gate_request([probability_list[0], probability_list[1]])
	else:
		_X_gate_request([probability_list[2], probability_list[3]])
		
	var state = yield(self,  "x_response_received")
	#print("TESTING, apply_X (3), state = " + String(state) + " entangle is "+ String(entangle))
	powerup_mutex.lock()
	if !entangle:
		x_backlist[backlist.find(pieces)][0] = state[0]
		x_backlist[backlist.find(pieces)][1] = state[1]
	
	else:
		x_backlist[backlist.find(pieces)][2] = state[0]
		x_backlist[backlist.find(pieces)][3] = state[1]
	powerup_mutex.unlock()
	
	#print("TESTING, apply_X (4), entangle is " + String(entangle) + " x_backlist is " +  String(x_backlist[x_backlist.size()-1]))
		
	_evaluate_superposition(state, "xgate")
	var eval_state = yield(self, "x_eval_response_received")
	#print("TESTING, apply_X (5), eval_state = " + String(eval_state) + " entangle is "+ String(entangle))
	powerup_mutex.lock()
	if !entangle:
		x_backlist_eval[backlist.find(pieces)][0] = (eval_state[0])
		x_backlist_eval[backlist.find(pieces)][1] = (eval_state[1])
	else:
		x_backlist_eval[backlist.find(pieces)][2] = (eval_state[0])
		x_backlist_eval[backlist.find(pieces)][3] = (eval_state[1])
	powerup_mutex.unlock()
	#print("TESTING, apply_X (6), entangle is " + String(entangle) + " x_eval_backlist is " + String(x_backlist_eval[x_backlist_eval.size()-1]))
		

##################### Game Functions
## new_game: Start a new game
func new_game(level):
	# hide the title screen
	$Start.visible = false
	# generate the next piece
	autoshift_action = ""
	$LockDelay.wait_time = 0.5
	$MidiPlayer.position = 0
	$Stats.new_game(level)
	
	next_pieces = backlist[0]

	
	new_piece()
	resume()

# The new piece gets generated
func new_piece():
	
	
	# current_piece, next_piece, etc. are all Tetromino objects
	# See res://Tetrominos/Tetromino.gd
	# Check the backlist
	# Thread this?
	if !running:# and !powerups_running:
		#Wait for thread to finish
		# Call new thread here
		backlist_thread.wait_to_finish()
		powerup_thread.wait_to_finish()
		running = true
		backlist_thread = Thread.new()
		backlist_thread.start(self,"handle_backlist")
		print("TESTING: another one!")
	
	#Transfer pieces
	if backlist.size() < 2:
		mutex.lock()
		powerup_mutex.lock()
		abort()
		mutex.unlock()
		powerup_mutex.unlock()
	
	current_pieces = backlist.pop_front()
	mutex.lock()
	next_pieces =  backlist[0]
	probabilities = probabilities_backlist.pop_front()
	mutex.unlock()
	
	powerup_mutex.lock()
	h_probabilities = h_backlist.pop_front()
	x_probabilities = x_backlist.pop_front()
		
	h_evals = h_backlist_eval.pop_front()
	x_evals = x_backlist_eval.pop_front()
	powerup_mutex.unlock()
	
	## powerup variables
	h_use = false
	x_use = false 
	#Move current pieces into position
	for current_piece in current_pieces:
		
		current_piece.visible = true
		if( current_piece.entanglement < 0 ):
			current_piece.translation = $Matrix/PosEntA.translation
		elif( current_piece.entanglement > 0 ):
			current_piece.translation = $Matrix/PosEntB.translation
		else:
			current_piece.translation = $Matrix/Position3D.translation
			#$FlashText.print("ERROR - NO ENTANGLEMENT")
		
		# Initializes the ghost-piece at the bottom
		current_piece.move_ghost()
	# Generates the next piece
	
	#Place next piece
	for next_piece in next_pieces: 
		next_piece.visible = true
		if(next_pieces.size()>2):
			next_piece.translation = $Next/Position3D.translation
			if next_piece.entanglement < 0:
				next_piece.translation = $Next/Position3D.translation + (Vector3(1,0,0))
			else:
				next_piece.translation = $Next/Position3D.translation + (Vector3(1,-4,0))
		else:
			# This places the next piece in the upper-right box
			next_piece.translation = $Next/Position3D.translation
	
	## Place current pieces
	# THERE is a 0-magnitude 3D-vector
	for current_piece in current_pieces:
		
		# Checks whether the piece has room to spawn
		if $Matrix/GridMap.possible_positions(current_piece.get_translations(), THERE, current_piece.entanglement):
			$DropTimer.start()
			current_piece_held = false
			
		# If the piece can't spawn, you lose!
		else:
			game_over()
		
	if (current_pieces.size() > 1 && current_pieces.size()<3):

		$FakeGhost.visible = true
		$FlashText.print("SUPERPOSITION")
		
		# If we have both superposition and entanglement,
	elif(current_pieces.size() > 2):
		$GhostB.visible = true
		$FakeGhostB.visible = true
		$FlashText.print("ENTANGLEMENT")
	else:
		$GhostB.visible = false
		$FakeGhost.visible = false

		$FakeGhostB.visible = false
		
	
	# If we have just entanglement,
	if (current_pieces[0].entanglement < 0): 
		$GhostB.visible = true
		$FakeGhostB.visible = false
	

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
			for current_piece in current_pieces:
				current_piece.turn(Tetromino.CLOCKWISE)
		if event.is_action_pressed("rotate_counterclockwise"):
			for current_piece in current_pieces:
				current_piece.turn(Tetromino.COUNTERCLOCKWISE)
		if event.is_action_pressed("hold"):
			hold()
		if event.is_action_pressed("hgate") and current_pieces.size()>1 and !h_use:
			h_use = true
			evaluate_probabilities("hgate")
		if event.is_action_pressed("xgate") and current_pieces.size()>1 and !x_use:
			x_use = true
			evaluate_probabilities("xgate")
			
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
	
	for current_piece in current_pieces:
		
		var moved
		
		# Move the the piece with the movement autoshift_action is currently assigned to.
		# autoshift_action needs to be reversed if piece-entanglement is positive
		if( current_piece.entanglement > 0 ):
			
			# If the piece is positively entangled,
			# Reverse lateral movement
			if( autoshift_action == "move_left" ): moved = current_piece.move(movements["move_right"])
			elif( autoshift_action == "move_right" ): moved = current_piece.move(movements["move_left"])
			else: moved = current_piece.move(movements["soft_drop"])
			
		# If the piece is either negatively entangled or not entangled at all,
		# behave normally
		else:
			moved = current_piece.move(movements[autoshift_action])
		
		# If the piece actually moved,
		# And 
		if moved != null and (autoshift_action == "soft_drop"):
			$Stats.piece_dropped(1)


# Called to instantly drop the piece to the bottom

func hard_drop():
	
	for current_piece in current_pieces:
		var score = 0
		
		# Stats
		# (Also drops the piece until it can be dropped no more)
		while current_piece.move(movements["soft_drop"]):
			score += 2
		$Stats.piece_dropped(score)
		
		
	# This code and below should be executed only once
	var translations = current_pieces[0].get_translations()
	for i in range(Tetromino.NB_MINOES):
		get_node("Matrix/DropTrail/"+str(i)).translation = translations[i]
		
		

	$Matrix/DropTrail.visible = true
	$Matrix/DropTrail/Delay.start()
	$LockDelay.stop()
	for current_piece in current_pieces:
		lock(current_piece)


# I can't find this timer.
# Maybe it was removed?
func _on_DropTrailDelay_timeout():
	$Matrix/DropTrail.visible = false


# Moves the piece down every certain amount of time.
# Based on level!
func _on_DropTimer_timeout():
	for current_piece in current_pieces:
		current_piece.move(movements["soft_drop"])
	

# After the amount of time the piece can sit on the ground before being locked, check that the piece is 
#still ready to be locked.

## LOOP FUNCTION, NOT DONE
func _on_LockDelay_timeout():
	for current_piece in current_pieces:
		if not $Matrix/GridMap.possible_positions(current_piece.get_translations(), movements["soft_drop"], current_piece.entanglement):
			lock(current_piece)


# Transforms the piece from a falling object to a group of blocks resting on the floor
##NOT DONE
func lock(current_piece):
	if(current_piece.is_fake):
		remove_child(current_piece)
		
	elif $Matrix/GridMap.lock(current_piece):
		var t_spin = current_piece.t_spin()
		var lines_cleared = $Matrix/GridMap.clear_lines()
		
		var super = ""
		if(current_pieces.size() > 1):
			if(current_pieces[1].is_fake): super = "SUPER"
		
		$Stats.piece_locked(lines_cleared, t_spin, super)
		
		if lines_cleared or t_spin:
			$MidiPlayer.piece_locked(lines_cleared)
		remove_child(current_piece)
		
	# If the piece doesn't successfully lock into the grid, game over!
	elif(playing == true):
		game_over()
	# Spawns the next piece after this one is locked to the ground.
		# If we're locking the last piece,
		# make the new pieces!
	if(current_pieces.find(current_piece) == current_pieces.size()-1):
		new_piece()

# Implements holding a piece in the upper left
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
				
			# Places the piece in the upper left box
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
	if(current_pieces[0].entanglement < 0):
		$GhostB.visible = true
		
	# Only make the fake ghost visible if there is a second piece AND we are superimposing
	#CHANGE THIS
	if( current_pieces.size() > 1):# && current_pieces[1].is_fake ): 
		$FakeGhost.visible = true
		
		if( current_pieces.size() > 2 ):
			$FakeGhostB.visible = true
		
	if held_pieces.size()>0:
		for held_piece in held_pieces:
			held_piece.visible = true
	for next_piece in next_pieces:
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
		for current_piece in current_pieces:
			current_piece.visible = false
		$Ghost.visible = false
		$GhostB.visible = false
		$FakeGhost.visible = false
		$FakeGhostB.visible = false
		if held_pieces.size()>0:
			for held_piece in held_pieces:
				held_piece.visible = false
		for next_piece in next_pieces:
			next_piece.visible = false

# Called when the player loses
func game_over():
	pause()
	$FlashText.print("GAME\nOVER")
	$ReplayButton.visible = true


# Called when the replay-button is pressed
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
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_FOCUS_OUT:
			if playing:
				pause($controls_ui)

func set_current_pieces(pieces):
	current_pieces = pieces

func get_current_pieces():
	return current_pieces
	
########################   Quantum Functionality   ######################## 
# switch probabilities and evaluation values
func evaluate_probabilities(action):
	if action == "hgate":
		# List of floats (probabilities - for display)
		probabilities = h_probabilities
		var index = 0
		for current_piece in current_pieces:
			print("TESTING, H Gate pressed,  index: " + String(index)+ "changing from: " + String(current_piece.get_is_fake()) + " to: " + String(h_evals[index]))
			if h_evals[index]:
				current_piece.set_fake()
			else:
				current_piece.set_real()
			index += 1
			
	elif action == "xgate":
			# List of floats (probabilities - for display)
		probabilities = x_probabilities
		
		var index = 0
		for current_piece in current_pieces:
			print("TESTING, X Gate pressed, index: " + String(index)+ "changing from: " + String(current_piece.get_is_fake()) + " to: " + String(h_evals[index]))
			if x_evals[index]:
				current_piece.set_fake()
			else:
				current_piece.set_real()
			index += 1

	else:
		print("Action not recognized")
	
########################## Http Request Fuctions

func _superposition_request():
	var headers = ["Content-Type: application/json"]
	# Add 'Content-Type' header:
#	print("TESTING, 3-_Superposition_Request, sending request ")
	$HTTPSuper.request("https://q-tetris-backend.herokuapp.com/api/createSuperposition",  headers, false, HTTPClient.METHOD_GET)

func _evaluate_superposition(probability_list, action):
	var headers = ["Content-Type: application/json"]
	# Add 'Content-Type' header:
	var prob = String(probability_list[0])
	if(action == "hgate"):
		$HTTPHEval.request("https://q-tetris-backend.herokuapp.com/api/determineSuperposition?prob=" + prob,  headers, false, HTTPClient.METHOD_GET)
	elif(action == "xgate"):
		$HTTPXEval.request("https://q-tetris-backend.herokuapp.com/api/determineSuperposition?prob=" + prob,  headers, false, HTTPClient.METHOD_GET)
	else:
		print("Creating request, action not recognized")

func _initial_evaluate_superposition():
	var headers = ["Content-Type: application/json"]
	# Add 'Content-Type' header:
	var prob
	if(init_entangled_pieces):
#		print("TESTING, 9-initial_evaluate_superposition, making eval request") 
		prob = String(probabilities_backlist.back()[2])
	else:
		prob = String(probabilities_backlist.back()[0])
#		print("TESTING, 12-initial_evaluate_superposition, making eval request") 
	$HTTPInitEval.request("https://q-tetris-backend.herokuapp.com/api/determineSuperposition?prob=" + prob,  headers, false, HTTPClient.METHOD_GET)

func _H_gate_request(probability_list):
### Build query
	var data_to_send = _create_request_data(probability_list)
	var query = JSON.print(data_to_send)
#	print("TESTING, H Gate Request Query " + String(query))
	#Add 'Content-Type' header:
	var headers = ["Content-Type: application/json"]	
	$HTTPH.request("https://q-tetris-backend.herokuapp.com/api/applyHGate",  headers, false, HTTPClient.METHOD_POST,query)

func _X_gate_request(probability_list):
	var data_to_send = _create_request_data(probability_list)
	var query = JSON.print(data_to_send)
#	print("TESTING, X Gate Request Query " + String(query))
	#Add 'Content-Type' header:
	var headers = ["Content-Type: application/json"]	
	$HTTPX.request("https://q-tetris-backend.herokuapp.com/api/applyXGate",  headers, false, HTTPClient.METHOD_POST,query)


func _create_request_data(probability_list):
	var data_to_send = {}
	var piece1 = {}
	var piece2 = {}

	piece1["prob"] = probability_list[0]
	piece1["type"] = 0 #piece_names[current_pieces[0].get_name()]
	piece2["prob"] = probability_list[1]
	piece2["type"] = 1 #piece_names[current_pieces[1].get_name()]

	data_to_send["piece1"] = piece1
	data_to_send["piece2"] = piece2
	return data_to_send


func _on_HTTPRequest_super_completed(result, response_code, headers, body):
	var response = JSON.parse(body.get_string_from_utf8())
#	print("TESTING, Superposition, response from Server: " + String(response.result))
	var to_append_prob = [0,0]
	var types = [0,0]
	to_append_prob[0] = response.result.result["piece1"]["prob"]
	to_append_prob[1] = response.result.result["piece2"]["prob"]
	
	var type0 = response.result.result["piece1"]["type"]
	var type1 = response.result.result["piece2"]["type"]
	if(type0>6):
		type0 = 6
	if(type1>6):
		type1 = 6
	types[0] = type0
	types[1] = type1

	emit_signal("super_response_received", {"prob":to_append_prob, "type": types})
		
func _on_HTTPRequest_init_eval_completed(result, response_code, headers, body):
	var response = JSON.parse(body.get_string_from_utf8())
	if(init_entangled_pieces):
#		print("TESTING, 13-_on_HTTPRequest_completed, setting second entangled pieces")
		init_entangled_pieces = false
		if(response.result["result"] == 0):
			backlist[backlist.size()-1][2].set_fake()
			backlist[backlist.size()-1][3].set_real() 
		elif(response.result["result"] == 1):
			backlist[backlist.size()-1][3].set_fake()
			backlist[backlist.size()-1][2].set_real()
		else:
			print("Initial Eval Response: Response code not recognized")
	else:
#		print("TESTING, 10-_on_HTTPRequest_completed, setting superposition or first entangled pieces")
#		print("TESTING Init eval with repsonse: " + String(response.result["result"]))
		if(response.result["result"] == 0):
			backlist[backlist.size()-1][0].set_fake()
			backlist[backlist.size()-1][1].set_real()
		elif(response.result["result"] == 1):
			backlist[backlist.size()-1][1].set_fake()
			backlist[backlist.size()-1][0].set_real()
		else:
			print("Initial Eval Response: Response code not recognized")
	emit_signal("init_eval_response_received")

func _on_HTTPRequest_Hgate_completed(result, response_code, headers, body):
	var response = JSON.parse(body.get_string_from_utf8())
#	print("TESTING, H Gate, response from Server: " + String(response.result.result))
	var to_send = [0,0]
	to_send[0] = response.result.result["piece1"]["prob"]
	to_send[1] = response.result.result["piece2"]["prob"]
		
	emit_signal("h_response_received", to_send)
	
func _on_HTTPRequest_Xgate_completed(result, response_code, headers, body):
	var response = JSON.parse(body.get_string_from_utf8())
#	print("TESTING, X Gate, response from Server: " + String(response.result.result))
	var to_send = [0,0]
	to_send[0] = response.result.result["piece1"]["prob"]
	to_send[1] = response.result.result["piece2"]["prob"]
#	print("TESTING, XGate Completed: " + String(to_send))
	emit_signal("x_response_received", to_send)

func _on_HTTPRequest_Heval_completed(result, response_code, headers, body):
	var response = JSON.parse(body.get_string_from_utf8())
	var to_send
	if(response.result["result"] == 0):
		to_send=[true, false]
	elif(response.result["result"] == 1):
		to_send = [false, true]
	else:
		print("Eval Response: Response code not recognized")
	
	emit_signal("h_eval_response_received", to_send)


func _on_HTTPRequest_Xeval_completed(result, response_code, headers, body):
	var response = JSON.parse(body.get_string_from_utf8())
	var to_send
	if(response.result["result"] == 0):
		to_send=[true, false]
	elif(response.result["result"] == 1):
		to_send = [false, true]
	else:
		print("Eval Response: Response code not recognized")
	
	emit_signal("x_eval_response_received", to_send)

# Bug, ghost - rafa
# Bug, all 4 entanglement pieces evaluated
# Graphics - cant tell superposition pieces apart
# Graphics - ghost needs to disappear before the piece hits. - Rafa
# Implement notifications for powerups when pressed
# GUI for powerups
# Probabilities on screen? How about in the notification?
# Limit amount of time a piece has to set
# Move game over button
# X powerups and h powerups should be separate threads
# PROBABILITIES FOR HOLDING
# THAT WIERD FALSE FALSE FALSE FALSE BUG
# If server hangs too long, abort and make normal piece
# ASync getting logging the new piece H and X gate stuff
# Integrate getting powerups list with allowing powerups etc