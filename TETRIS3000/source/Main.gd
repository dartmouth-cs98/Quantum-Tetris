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

# Boolean - used to prevent code from breaking if user holds down the hold-piece-command
var current_piece_held

# Stores a movement when the player holds down a key
var autoshift_action

# Boolean - false while game is paused,
# and set to true when player starts playing
var playing = false

## Creating Pieces
var running = false

## For MultiThreading
var thread
var mutex

## For requests
var current_names = []
var next_names = []

## idk
var turns = 4

## From response for create piece
var types = [0,0,0,0]

## For responce
var super_response = false
var gate_response = false
var init_eval_response = false
var eval_response = false
var entangled_pieces = false

##Signals
signal response_received
signal have_pieces

##################### Functions ##################### 
## _ready: Randomize random number generator seeds
func _ready():
	randomize()
	running = true
	mutex = Mutex.new()
	thread = Thread.new()
	thread.start(self,"handle_backlist")
	


##################### Handle Piece Backlist
func handle_backlist(userdata):
	var num_turns = 10
	var total_pieces = backlist.size()
	for i in range(num_turns - total_pieces):
		var turn_type = count_turns()
		var to_append = []
		# Superposition
		
		if(turn_type == 1):
#			print("TESTING, 1-Handle_Backlist, adding superposition to backlist")
			# Get Pieces
			random_piece(true, false)
			yield(self, "have_pieces")
			
#			print("TESTING, 8-Handle_Backlist, have pieces, calling evaluate") 
			# Determine which pieces are fake
			_initial_evaluate_superposition()
			yield(self, "response_received")
#			print("TESTING, 11-Handle_Backlist, done adding super piece") 
		# Superposition and Entanglement
		elif(turn_type == 2):
#			print("TESTING, 1-Handle_Backlist, adding entanglement to backlist")
			random_piece(true, true)
			yield(self, "have_pieces")

			# Determine which pieces are fake
#			print("TESTING, 8-Handle_Backlist, have pieces, calling evaluate") 
			_initial_evaluate_superposition()
			yield(self, "response_received")
			entangled_pieces = true
#			print("TESTING, 11-Handle_Backlist, have pieces, calling evaluate") 
			_initial_evaluate_superposition()
			yield(self, "response_received")
#			print("TESTING, 14-Handle_Backlist, done adding entangled pieces") 
		else:
			random_piece(false, false)
#			print("TESTING, 1-Handle_Backlist, adding normal to backlist")

		for piece in backlist[backlist.size()-1]:#to_append:
			piece.visible = false

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


	if (create_entanglement && create_super_piece): 
#		print("TESTING, 2-Random_Piece, creating first entanglement pieces and calling request")
		
		# Call superposition request, which gets piece probabilities and types
		_superposition_request()
		
		# Wait till http request node received a server responce
		yield(self, "response_received")
#		print("TESTING, 5-Random_Piece, back in Random_Piece")
		# instantiate the piece returned by server
		var piece0 = return_name(types[0]).instance()
		# add it to pieces list
		pieces.append(piece0)
		# add piece to the game board
		add_child(piece0)
		
		var piece1 = return_name(types[1]).instance()
		pieces.append(piece1)
		add_child(piece1)
		
#		print("TESTING, 2-Random_Piece, creating second entanglement pieces and calling request")
		# Repeat for pieces 2 and 3 (during entanglement)
		entangled_pieces = true
		_superposition_request()
		yield(self, "response_received")
#		print("TESTING, 5-Random_Piece, back in Random_Piece")
		var piece2 = return_name(types[2]).instance()
		pieces.append(piece2)
		add_child(piece2)
		
		var piece3 = return_name(types[3]).instance()
		pieces.append(piece3)
		add_child(piece3)
		

		
		pieces[0].entangle(-1)
		pieces[1].entangle(-1)
		pieces[2].entangle(1)
		pieces[3].entangle(1)
#		print("TESTING, 6-Random_Piece, result: " + String(pieces))

		
	elif create_super_piece:
#		print("TESTING, 2-Random_Piece, creating superpiece and calling superposition")
		_superposition_request()
	
		yield(self, "response_received")
#		print("TESTING, 5-Random_Piece, back in Random_Piece")

		var piece1 = return_name(types[0]).instance()
		piece1.entangle(0)
		pieces.append(piece1)
		add_child(piece1)
		
		var piece2 = return_name(types[1]).instance()
		piece2.entangle(0)
		pieces.append(piece2)
		add_child(piece2)
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
		
		# Add placeholder in probabilities_backlist
		probabilities_backlist.append([0,0,0,0])
			
	# Reset other variables (types)
	types = [-1,-1,-1,-1]
	
	# Add pieces to backlist, emit completed signal, and exit
	backlist.append(pieces)
#	print("TESTING, 7-Random_Piece, added pieces to backlist")
	emit_signal("have_pieces")
	
func return_name(i):
	for key in piece_scene_to_int.keys():
		if piece_scene_to_int[key] == i:
			return key
			
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
	
	next_pieces = backlist.pop_front()
	new_piece()
	resume()

# The new piece gets generated
func new_piece():
	
	
	# current_piece, next_piece, etc. are all Tetromino objects
	# See res://Tetrominos/Tetromino.gd
	# Check the backlist
	# Thread this?
	if !running:
		#Wait for thread to finish
		# Call new thread here
		
		running = true
		#handle_backlist()
	
	#Transfer pieces
	current_pieces = next_pieces
	next_pieces = backlist.pop_front()
	probabilities = probabilities_backlist.pop_front()
		
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
		
	if (current_pieces.size() > 1 && current_pieces.size()<3):# && current_pieces[1].is_fake):
		$FakeGhost.visible = true
		$FlashText.print("SUPERPOSITION")
		
		# If we have both superposition and entanglement,
	elif(current_pieces.size() > 2):
		$GhostB.visible = true
		$FakeGhostB.visible = true
		$FlashText.print("ENTANGLEMENT")
	else:
		$GhostB.visible = true
		$FakeGhost.visible = false
		
		$FakeGhostB.visible = false

	

# Increments the difficulty upon reaching a new level
##DONE
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

func evaluate_probabilities(action):
	if action == "hgate":
		_H_gate_request()
		yield(self, "response_received")
		_evaluate_superposition()
		yield(self, "response_received")

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

		if current_pieces.size()>2:
			entangled_pieces = true
			_X_gate_request()
			yield(self, "response_received")
			_evaluate_superposition()
			yield(self, "response_received")
	else:
		print("Action not recognized")
	
########################## Http Request Fuctions

func _superposition_request():
	var headers = ["Content-Type: application/json"]
	# Add 'Content-Type' header:
	super_response = true
#	print("TESTING, 3-_Superposition_Request, sending request ")
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
	
func _initial_evaluate_superposition():
	var headers = ["Content-Type: application/json"]
	# Add 'Content-Type' header:
	init_eval_response = true
	var prob
	if(entangled_pieces):
#		print("TESTING, 9-initial_evaluate_superposition, making eval request") 
		prob = String(probabilities_backlist.back()[2])
	else:
		prob = String(probabilities_backlist.back()[0])
#		print("TESTING, 12-initial_evaluate_superposition, making eval request") 
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
		piece1["type"] = 2 #piece_names[current_pieces[2].get_name()]
		piece2["prob"] = probabilities[3]
		piece2["type"] = 3 #piece_names[current_pieces[3].get_name()]
	else:
		piece1["prob"] = probabilities[0]
		piece1["type"] = 0 #piece_names[current_pieces[0].get_name()]
		piece2["prob"] = probabilities[1]
		piece2["type"] = 1 #piece_names[current_pieces[1].get_name()]
	data_to_send["piece1"] = piece1
	data_to_send["piece2"] = piece2
	return data_to_send

# For creating HTTP Request Nodes on the fly
func _send_data():
	pass

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var response = JSON.parse(body.get_string_from_utf8())
	if (super_response):
		super_response = false
#		print("TESTING, 4-_on_HTTPRequest_request, creating superposition request ")
		if(entangled_pieces):
			entangled_pieces = false
			probabilities_backlist[probabilities_backlist.size()-1][2] = response.result.result["piece1"]["prob"]
			probabilities_backlist[probabilities_backlist.size()-1][3] = response.result.result["piece2"]["prob"]
			
			var type2 = response.result.result["piece1"]["type"]
			var type3 = response.result.result["piece2"]["type"]
			if(type2>6):
				type2 = 6
			if(type3>6):
				type3 = 6
			
			types[2] = type2
			types[3] = type3
		else:
			var to_append_prob = [0,0,0,0]
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
			probabilities_backlist.append(to_append_prob)
			
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
			if(response.result["result"] == 0):
				current_pieces[2].set_fake()
				current_pieces[3].set_real()
			elif(response.result["result"] == 1):
				current_pieces[3].set_fake()
				current_pieces[2].set_real()
			else:
				print("Eval Response: Response code not recognized")
		else:
			if(response.result["result"] == 0):
				current_pieces[0].set_fake()
				current_pieces[1].set_real()
			elif(response.result["result"] == 1):
				current_pieces[1].set_fake()
				current_pieces[0].set_real()
			else:
				print("Eval Response: Response code not recognized")
	elif(init_eval_response):
		init_eval_response = false

		if(entangled_pieces):
#			print("TESTING, 13-_on_HTTPRequest_completed, setting second entangled pieces")
			entangled_pieces = false
			if(response.result["result"] == 0):
				backlist[backlist.size()-1][2].set_fake()
				backlist[backlist.size()-1][3].set_real() 
			elif(response.result["result"] == 1):
				backlist[backlist.size()-1][3].set_fake()
				backlist[backlist.size()-1][2].set_real()
			else:
				print("Initial Eval Response: Response code not recognized")
		else:
#			print("TESTING, 10-_on_HTTPRequest_completed, setting first entangled pieces")
#			print("TESTING Init eval with repsonse: " + String(response.result["result"]))
			if(response.result["result"] == 0):
				backlist[backlist.size()-1][0].set_fake()
				backlist[backlist.size()-1][1].set_real()
			elif(response.result["result"] == 1):
				backlist[backlist.size()-1][1].set_fake()
				backlist[backlist.size()-1][0].set_real()
			else:
				print("Initial Eval Response: Response code not recognized")

	else:
		print("Response type not known")
	emit_signal("response_received")


# Bug, ghost
# Bug, all 4 entanglement pieces evaluated
# Graphics - cant tell superposition pieces apart
# Graphics - ghost needs to disappear before the piece hits.
# Error 500 on X gate, but not on H gate
# Entanglement, says game over
# Implement notifications for powerups when pressed
# GUI for powerups
# Probabilities on screen? How about in the notification?
# Limit piece setting time