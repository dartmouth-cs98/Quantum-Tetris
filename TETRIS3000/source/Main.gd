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

## Creating Pieces
var create_super_piece = true
var create_entanglement = false

## Probabilities
var probabilities = [0.49,0.51,0.14,0.86]

## For requests
var current_names = []
var next_names = []


## For responce
var super_response = false
var gate_response = false
var eval_response = false
var entangled_pieces = false

##Signals
signal response_received

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
		
		if (!create_entanglement): 
			# This is the line that places the piece in the middle of the center grid when it starts falling
			current_piece.translation = $Matrix/Position3D.translation
		
		else:
			if( current_piece.entanglement < 0 ):
				current_piece.translation = $Matrix/PosEntA.translation
			elif( current_piece.entanglement > 0 ):
				current_piece.translation = $Matrix/PosEntB.translation
			else:
				current_piece.translation = $Matrix/Position3D.translation
				$FlashText.print("ERROR")
		
		# Initializes the ghost-piece at the bottom
		current_piece.move_ghost()
	
	# Generates the next piece
	next_pieces = random_piece()
	
	for next_piece in next_pieces:
		
		# This places the next piece in the upper-right box
		next_piece.translation = $Next/Position3D.translation
	
	# THERE is a 0-magnitude 3D-vector
	for current_piece in current_pieces:
		
		# Checks whether the piece has room to spawn
		if $Matrix/GridMap.possible_positions(current_piece.get_translations(), THERE, current_piece.entanglement):
			$DropTimer.start()
			current_piece_held = false
			
		# If the piece can't spawn, you lose!
		else:
			game_over()
		
	if (current_pieces.size() > 1 && create_super_piece):
		$FakeGhost.visible = true
		
		# If we have both superposition and entanglement,
		if(current_pieces.size() >= 4):
			$FakeGhostB.visible = true
	else:
		$FakeGhost.visible = false
		
		$FakeGhostB.visible = false

## random_piece: Generate a random piece
## IMPLEMENT FUNCTIONS FOR ACTUALLY DETERMINING SUPERPOSITION
## AND ENTANGLEMENT
func random_piece():
	
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
	
	# Add first piece
	var pieces = []
	pieces.append(piece)
	add_child(piece)

	if (create_entanglement && create_super_piece): 
		pieces.append(create_superposition(pieces, true))
		pieces.append(create_superposition(pieces, false))
		pieces.append(create_superposition(pieces, true))
		
		pieces[0].entangle(-1)
		pieces[1].entangle(-1)
		pieces[2].entangle(1)
		pieces[3].entangle(1)
		$FlashText.print("ENTANGLEMENT")
		
	elif create_entanglement:
		
		# Appends the second piece
		# (and adds it as a child to the tree within the function)
		pieces.append(create_superposition(false))
		
		# Entangles the two pieces
		pieces[0].entangle(-1)
		pieces[1].entangle(1)
		
		$FlashText.print("ENTANGLEMENT")
		
		
	elif create_super_piece:
		pieces.append(create_superposition(true))
		$FlashText.print("SUPERPOSITION")
		
		
			
	# Returns the piece randomly selected from random_bag
	return pieces
	
	
func create_superposition(is_fake):  	# create a superposition piece
	var second_choice = randi() % random_bag.size()
	var second_piece = random_bag[second_choice].instance()
	random_bag.remove(second_choice)
	second_piece.entangle(0)
		
	# pieces.append(second_piece)
	add_child(second_piece)
			
	############## FOR TESTING ############## 
	if is_fake:
		second_piece.set_fake()
	############## TESTING DONE ############## 
	# evaluate which piece is the superposition piece
	# turn off create_superposition
	return second_piece
	

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
		if event.is_action_pressed("hgate") and current_pieces .size()>1:
			evaluate_probabilities("hgate")
		if event.is_action_pressed("xgate") and current_pieces.size()>1:
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
		if(create_super_piece): super = "SUPER"
		
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
	if(create_entanglement):
		$GhostB.visible = true
	
	# Only make the fake ghost visible if there is a second piece AND we are superimposing
	if( current_pieces.size() > 1 && create_super_piece == true ): 
		$FakeGhost.visible = true
		
		if( current_pieces.size() >= 4 ):
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

########################   Quantum Functionality   ######################## 

func evaluate_probabilities(action):
	if action == "hgate":
		_H_gate_request()
		yield(self, "response_received")
		_evaluate_superposition()
		yield(self, "response_received")
		print("After Eval, Piece 0 is_fake: ", current_pieces[0].get_is_fake())
		print("After Eval, Piece 1 is_fake: ", current_pieces[1].get_is_fake())

		if current_pieces.size()>2:
			entangled_pieces = true
			_H_gate_request()
			yield(self, "response_received")
			_evaluate_superposition()
			yield(self, "response_received")
			
	elif action == "xgate":
		_X_gate_request()
		yield(self, "response_received")
		_evaluate_superposition()
		yield(self, "response_received")
		print("After Eval, Piece 0 is_fake: ", current_pieces[0].get_is_fake())
		print("After Eval, Piece 1 is_fake: ", current_pieces[1].get_is_fake())

		if current_pieces.size()>2:
			entangled_pieces = true
			_X_gate_request()
			yield(self, "response_received")
			_evaluate_superposition()
			yield(self, "response_received")
	else:
		print("Action not recognized")
		
		

func set_current_pieces(pieces):

	current_pieces = pieces

func get_current_pieces():

	return current_pieces
	
	
	
########################## Http Request Fuctions
#
func _superposition_request():
	var headers = ["Content-Type: application/json"]
	# Add 'Content-Type' header:
	super_response = true
	$HTTPRequest.request("https://q-tetris-backend.herokuapp.com/api/createSuperposition",  headers, false, HTTPClient.METHOD_GET)

func _evaluate_superposition():
	var headers = ["Content-Type: application/json"]
	# Add 'Content-Type' header:
	eval_response = true
	var prob
	if(entangled_pieces):
		prob = String(probabilities[2])
	else:
		prob = String(probabilities[0])
	$HTTPRequest.request("https://q-tetris-backend.herokuapp.com/api/determineSuperposition?prob=" + prob,  headers, false, HTTPClient.METHOD_GET)

func _H_gate_request():
### Build query
	var data_to_send = _create_request_data(entangled_pieces)
	var query = JSON.print(data_to_send)
	#Add 'Content-Type' header:
	var headers = ["Content-Type: application/json"]	
	gate_response = true
	$HTTPRequest.request("https://q-tetris-backend.herokuapp.com/api/applyHGate",  headers, false, HTTPClient.METHOD_POST,query)

func _X_gate_request():
	var data_to_send = _create_request_data(entangled_pieces)
	var query = JSON.print(data_to_send)
	#Add 'Content-Type' header:
	var headers = ["Content-Type: application/json"]	
	gate_response = true
	$HTTPRequest.request("https://q-tetris-backend.herokuapp.com/api/applyXGate",  headers, false, HTTPClient.METHOD_POST,query)


func _create_request_data(entangle):
	var data_to_send = {}
	var piece1 = {}
	var piece2 = {}
	if entangle:
		piece1["prob"] = probabilities[2]
#		piece1["type"] = piece_names[current_pieces[2].get_name()]
		piece2["prob"] = probabilities[3]
#		piece2["type"] = piece_names[current_pieces[3].get_name()]
	else:
		piece1["prob"] = probabilities[0]
#		piece1["type"] = piece_names[current_pieces[0].get_name()]
		piece2["prob"] = probabilities[1]
#		piece2["type"] = piece_names[current_pieces[1].get_name()]
	data_to_send["piece1"] = piece1
	data_to_send["piece2"] = piece2
	return data_to_send

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var response = JSON.parse(body.get_string_from_utf8())
	if (super_response):
		super_response = false
		#update probabilities
		
		if(entangled_pieces):
			entangled_pieces = false
		else:
			pass
	elif(gate_response):
		gate_response = false
		
		if(entangled_pieces):
			entangled_pieces = false
			probabilities[2] = response.result.result["piece1"]["prob"]
			probabilities[3] = response.result.result["piece2"]["prob"]
		else:
			probabilities[0] = response.result.result["piece1"]["prob"]
			probabilities[1] = response.result.result["piece2"]["prob"]
	elif(eval_response):
		eval_response = false

		if(entangled_pieces):
			entangled_pieces = false
			#eval other pieces
		else:
			print("Eval Response: " + String(response.result["result"]))
			if(response.result["result"] == 0):
				print("Hit 0")
				current_pieces[0].set_fake()
				current_pieces[1].set_real()
			elif(response.result["result"] == 1):
				print("Hit 1")
				current_pieces[1].set_fake()
				current_pieces[0].set_real()
			else:
				print("Eval Response: Response code not recognized")
		#change is_trues?

	else:
		print("Response type not known")
	emit_signal("response_received")
