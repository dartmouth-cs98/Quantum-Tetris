tool
extends Node2D

#########################   Signals, Constants, Variables   ##########################

##Signals that this script will broadcast
#Connects to _on_board_pause() in main.gd
signal pause
#Connects to _on_board_game_over() in main.gd
signal game_over

### Game States
## Determines behavior in _input, _process, and _end_block
# Enum is a collection of constants, in this case showing game state.
enum GameState {RUNNING, COMPLETED_LINES, OVER, STOPPED}

#Load Falling Tile scene
const FallingTile = preload("res://falling_tile.tscn")

########## Constants for Physics and Game Control
#Starting max amount of time before block can automatically move
const START_BLOCK_TIME = 0.5
# Starting max amount of time before a player can move a block
const START_MOVE_TIME = 0.1
#Other
const BLOCK_ACCEL = 0.1
const LINES_PER_LEVEL = 10

########## Constants for Board Setup and Block Queue
const BORDER_TILE_NAME = "grey"
const COMPLETED_TILE_NAME = "white"

const BLOCKS_PER_QUEUE = 7

########## Array of block shapes held as scenes
var _block_types = [
	preload("res://blocks/i.tscn"),
	preload("res://blocks/j.tscn"),
	preload("res://blocks/l.tscn"),
	preload("res://blocks/o.tscn"),
	preload("res://blocks/s.tscn"),
	preload("res://blocks/t.tscn"),
	preload("res://blocks/z.tscn")
]

########## Export board_size
# Allow board_size to be visible in the inspector 
# setget defines a _set_size method that will be called to set the variable instead
#of allowing other functions to modify it themselves.
export(Vector2) var board_size = Vector2(10, 20) setget _set_size


########## General variables for blocks and block queue
# Upcoming blocks, not shown. Is array type
var _block_queue
# Block currently on screen
var _block

########## Superpositon
# is this block a superposition
var _is_sp
# counter till next superposition
var _sp_counter
# the block our superposition block will evaluate to
var _true_block
# when will the superposition block be loaded
var _sp_hit_counter
# if entanglement is activated
var entanglement = {}

var response

var temp_block_i
var temp_block_j

var temp_prob
var temp_server



########## Variables for moving a block down a notch
# Max time between plater block movements
var _max_move_time
# Max time between automatic block movements
var _max_block_time
# Current time between automatic block movements
var _block_time
# Current time between player block movements
var _move_time
# Other
var _grace
var _lines_left
var _completed_lines

########## Variables for Game State
var _game_state

########## Variables for Speed node
var speeds = ["x1", "x2", "x3"]
var speed_i = 1

##############################   Functions   ################################


########################### Initialization and Board Setup Functions

## Ready
# When the node enters the tree, the game state is 'stopped' initially
# Completed lines is empty
func _ready():
	_game_state = GameState.STOPPED
	_completed_lines = []

## _set_size
# set_size sets the size of the board and lines tiles around it. 
func _set_size(value):
	board_size = value

	#If the board has tiles.
	if get_child_count() > 0:
		#Clear the tiles from tilemap (child of board)
		$board_tiles.clear()
		
		#Get tile for the border of the board
		var border_tile = $board_tiles.tile_set.find_tile_by_name(
				BORDER_TILE_NAME)
		
		#For debugging, ignored in non debug builds
		assert(border_tile != null)

		## Populate the tile map 
		# Top and bottom
		for x in range(board_size.x + 2):
			$board_tiles.set_cell(x, 0, border_tile)
			$board_tiles.set_cell(x, board_size.y + 1, border_tile)

		# Left and right
		for y in range(1, board_size.y + 1):
			$board_tiles.set_cell(0, y, border_tile)
			$board_tiles.set_cell(board_size.x + 1, y, border_tile)

func start_game():
	randomize()

	#set game state to running, allow _input and start _process.
	_game_state = GameState.RUNNING

	# set queue variables
	_block_queue = []
	_generate_block_queue()

	#set block variables
	_block = null

	# Set physics variables
	_max_block_time = START_BLOCK_TIME
	_max_move_time = START_MOVE_TIME
	_block_time = _max_block_time
	_move_time = _max_move_time 
	
	# set superposition variables
	_sp_counter = superposition_counter()
	_is_sp = false
	
	# set other variables
	_grace = false
	_lines_left = LINES_PER_LEVEL
	# Start the game!
	_spawn_inter()

########################### Input and Process Functions
func _input(event):
	if not Engine.editor_hint and (_game_state == GameState.RUNNING):
		if event.is_action_pressed("cancel"):
			get_tree().set_input_as_handled()
			emit_signal("pause")
		elif _block:
			if event.is_action_pressed("drop"):
				_drop_block_fast()
			else:
				var move_left = event.is_action_pressed("move_left")
				var move_right = event.is_action_pressed("move_right")
				var move_down = event.is_action_pressed("move_down")

				_control_block(
						move_left,
						move_right,
						move_down,
						event.is_action_pressed("rotate_ccw"),
						event.is_action_pressed("rotate_cw")
						)

				if move_left or move_right or move_down:
					_move_time += _max_move_time
				if move_down:
					_block_time += _max_block_time

func _process(delta):
	if not Engine.editor_hint and (_game_state != GameState.STOPPED):
		if _game_state == GameState.RUNNING:
			var block_dropped = false
			# Decrement block time
			_block_time -= delta
			# If the block time has run out, move the block down a cell or generate a new one.
			if _block_time <= 0:
				# If the block exists, drop it by one cell
				if _block:
					_drop_block()
					block_dropped = true
					_block_time += _max_block_time

			if _block:
				_move_time -= delta

				var can_move = _move_time <= 0

				var move_left = Input.is_action_pressed("move_left") \
						and can_move
				var move_right = Input.is_action_pressed("move_right") \
						and can_move
				# Don't drop block manually if it's already falling fast enough
				# naturally. Deleted and (_max_block_time > _max_move_time)
				var move_down = Input.is_action_pressed("move_down") \
						and can_move and not block_dropped	

				_control_block(move_left, move_right, move_down, false, false)

				
				if can_move:
					_move_time += _max_move_time
			# By putting this here, the program gets a new block as soon as the old one hits
			# the problem with reading if it hit or not has to do with time values
			else:
				_spawn_inter()
			# because drawing entanglement in spawn is slow (this is slow too)
			if entanglement.size()>0:
				for key in entanglement.keys():
					var new_tile_int = -1
					if(entanglement[key] == 1):
						new_tile_int = randi() % _block_types.size()
					$board_tiles.set_cellv(key, new_tile_int)
				entanglement.clear()
		## If the falling block animation is over, end the game.
		elif _game_state == GameState.OVER:
			# If all falling tiles are off screen
			if $falling_tiles.get_child_count() == 0:
				end_game()
### _on_TopGUI_speed_change
func _on_TopGUI_speed_change():
	speed_i = wrapi(speed_i+1, 1, speeds.size()+1)
	_max_block_time = (START_BLOCK_TIME/ float(speed_i))
	_max_move_time = (START_MOVE_TIME/float(speed_i))

########################### Manage Block Queue
##_spawn_inter
# this needs to: show next pieces, spawn blocks, determine superposition

func _spawn_inter():
	### Check block queue size
	if _block_queue.size()<3:
		_generate_block_queue()
	
	### Superposition 
	
	# determine superposition
	if (_sp_counter == 0):
		_is_sp = true
		_sp_counter = superposition_counter()
		# YEETT  - change this to just give array to set superposition and get two blocks
		var result = set_superposition(_block_types)
		_block_queue.insert(2, result) 

	else:
		_sp_counter -= 1
	### Spawn handle next block 
	_spawn_block()
	
	### Update Nexts
	$SideGUI.change_next(_block_queue[0], _block_queue[1])
	

func _spawn_block():
	# get block from queue
	var _poten_block = _block_queue.pop_front()
	if _poten_block.get_class()=="PackedScene":
		_block = _poten_block.instance()
	else:
		_block = _poten_block
	add_child(_block)

	var block_rect = _block.get_rect()

	#Find the middle of the board and block
	var board_middle = int(board_size.x / 2)
	var block_middle = int(block_rect.size.x / 2)

	#BLock will spawn in the middle of the board
	var block_pos = Vector2(board_middle - block_middle + 1, 1)
	_block.block_position = block_pos
	
	# Reset block time when a new block is spawned
	_block_time = _max_block_time

	#If the spawn point is blocked, then game over.
	if not _is_block_space_empty(block_pos, 0):
		_set_game_over()
		

## _generate_block_queue
# Add a certain number of blocks of each type
# Randomize the list
func _generate_block_queue():
	for b in _block_types:
		#warning-ignore:unused_variable
		for i in range(BLOCKS_PER_QUEUE):
			_block_queue.append(b)
	_block_queue.shuffle()
	

########################### Control Blocks Functions
## Generate the commands to control the block
# Pass onto move_block
func _control_block(move_left, move_right, move_down, rotate_ccw, rotate_cw):
	var move = Vector2()
	var rotate = 0

	if move_left:
		move.x -= 1
	if move_right:
		move.x += 1
	if move_down:
		move.y += 1

	if rotate_ccw:
		rotate -= 1
	if rotate_cw:
		rotate += 1

	_move_block(move, rotate)

## Make changes to the block based on controls.
func _move_block(pos, rot):
	var new_pos = _block.block_position + pos
	var new_rot = _block.block_rotation + rot

	if _is_block_space_empty(new_pos, new_rot):
		_block.block_position = new_pos
		_block.block_rotation = new_rot
		_check_stop()
			
## _drop_block
# Move the block down one unit
func _drop_block():
	# Move the block down a unit
	_move_block(Vector2(0, 1), 0)
	_check_stop()
	# If the space below this block isnt empty

func _drop_block_fast():
	while _block:
		_drop_block()

func _check_stop():
	if not _is_block_space_empty(_block.block_position + Vector2(0, 1),
			_block.block_rotation):
		if _grace:
			_end_block()
			_grace = false
			_block_time = 0
		else:
			_grace = true
			_block_time -= _max_block_time / 2.0

## _is_block_space_empty
# Given a position and rotation value, check if cells are occupied
func _is_block_space_empty(pos, rot):
	# Assume that block space is empty
	var result = true
	# for every tile position
	for t in _block.get_tiles(pos, rot):
		# an occupied cell has a positive integer value
		if $board_tiles.get_cellv(t) != -1:
			result = false
			break
	return result

func _end_block():
	var tiles = _block.get_tiles()
	## HERE is where I covert it to block type
	if(_is_sp):
		if(_sp_hit_counter<1):
			switch_blocks(_true_block)
			if temp_server == temp_prob:
				_make_entanglement_request()
			temp_block_i = null
			temp_block_j = null
			
			_is_sp = !_is_sp
			reset_superposition()
			
		else:
			_sp_hit_counter -= 1	
		
	
	for t in tiles:
		$board_tiles.set_cellv(t + _block.block_position,
				_block.get_tile_type(t))

	_block.queue_free()
	_block = null
	# if last piece was in superposition, reset it.
	
	

	if _game_state == GameState.RUNNING:
		_check_for_completed_lines()
#### _check_for_completed_lines
### Check for lines to get rid of.
# Will also trigger game over if cells are found in every line
# Goes from bottom to top, checking across each line
func _check_for_completed_lines():
	#Bottom to top
	for y in range(board_size.y, 0, -1):
		#Assume that the line is true
		var complete = true
		for x in range(1, board_size.x + 1):
			#If there isnt a cell, set complete as false
			if $board_tiles.get_cell(x, y) == -1:
				complete = false
				break
		#Move lines to completed lines scene
		if complete:
			_completed_lines.append(y)
			$TopGUI._update_score( _completed_lines.size())
			
	_lines_left -= _completed_lines.size()
	while _lines_left <= 0:
		_lines_left += LINES_PER_LEVEL
		_max_block_time -= BLOCK_ACCEL
		_max_block_time = max(_max_block_time, _max_move_time)

	if not _completed_lines.empty():
		_show_completed_lines()

########################### Level Completed Functions

## Level over animation
func _show_completed_lines():
	# Change game state
	_game_state = GameState.COMPLETED_LINES

	var completed_tile = $completed_lines.tile_set.find_tile_by_name(
			COMPLETED_TILE_NAME)
	assert(completed_tile != null)

	for y in _completed_lines:
		for x in range(1, board_size.x + 1):
			$completed_lines.set_cell(x, y, completed_tile)
	$completed_animation.play("completed")

func _on_completed_animation_animation_finished( anim_name ):
	assert(anim_name == "completed")

	$completed_lines.clear()

	while not _completed_lines.empty():
		var current_y = _completed_lines.front()

		_completed_lines.pop_front()
		for i in range(_completed_lines.size()):
			_completed_lines[i] += 1

		for x in range(1, board_size.x + 1):
			for y in range(current_y, 0, -1):
				if y - 1 > 0:
					var tile_above = $board_tiles.get_cell(x, y - 1)
					$board_tiles.set_cell(x, y, tile_above)
				else:
					$board_tiles.set_cell(x, y, -1)

	_game_state = GameState.RUNNING

########################### Game Over Functions
## _set_game_over()
# Called if spawn point if filled. Start end_game animation
func _set_game_over():
	_end_block()
	_game_state = GameState.OVER
	_spawn_falling_blocks()

## _spawn_falling_blocks
# Is this spinning tile shit.
func _spawn_falling_blocks():
	for x in range(1, board_size.x + 1):
		for y in range(1, board_size.y + 1):
			# Find all cells in tileset (all have unqiue integer id not -1)
			if $board_tiles.get_cell(x, y) != -1:
				# Set the found tile to a falling_block instance
				var tile = FallingTile.instance()
				tile.set_tile($board_tiles, Vector2(x, y))
				$falling_tiles.add_child(tile)
				# set the space to occupied
				$board_tiles.set_cell(x, y, -1)

## end_game
# After animation is over, finish ending the game
func end_game():
	#Error catching?
	if _block != null:
		_end_block()
	for x in range(1, board_size.x + 1):
		for y in range(1, board_size.y + 1):
			$board_tiles.set_cell(x, y, -1)
	_game_state = GameState.STOPPED
	emit_signal("game_over")

########################### SuperPosition Functions

############ Main Functions
func set_superposition(block_array):
	# Generate two different indices
	var i = (randi() % (block_array.size()))
	var j = (randi() % (block_array.size()))
	while j == i:
		j = (randi() % (block_array.size()))
	
	# Get PackedScenes for blocks
	var blockP_i = block_array[i]
	var blockP_j = block_array[j]
	
	# Generate probabilities
	var prob1 = randi() % 100 + 1
	var prob2 = 100 - prob1
	
	if prob1>50:
		temp_prob = 1
	else:
		temp_prob = 0
	# Get block nodes from PackedScenes
	var block_i = blockP_i.instance()
	var block_j = blockP_j.instance()
	
	var tiles_array_0 = block_i.get_tiles() + block_j.get_tiles()
	block_i._set_block_rotation(1)
	block_j._set_block_rotation(1)
	var tiles_array_1 = block_i.get_tiles() + block_j.get_tiles()
	block_i._set_block_rotation(2)
	block_j._set_block_rotation(2)
	var tiles_array_2 = block_i.get_tiles() + block_j.get_tiles()
	block_i._set_block_rotation(3)
	block_j._set_block_rotation(3)
	var tiles_array_3 = block_i.get_tiles() + block_j.get_tiles()
	
	var result = Node2D.new()
	
	var orientation1 = set_orientation(tiles_array_0)
	var orientation2 = set_orientation(tiles_array_1)
	var orientation3 = set_orientation(tiles_array_2)
	var orientation4 = set_orientation(tiles_array_3)
	
	
	result.add_child(orientation1)
	result.add_child(orientation2)
	result.add_child(orientation3)
	result.add_child(orientation4)
	
	orientation1.owner = result
	orientation2.owner = result
	orientation3.owner = result
	orientation4.owner = result
	
	result.set_script(load("res://blocks/block.gd"))
	
	#CONNECT TO SERVER
	_make_superposition_request(prob1)
	
	_true_block = block_i
	
	temp_block_i = block_i
	temp_block_j = block_j
	# Update the UI	
	$SideGUI.set_superposition_data(prob1, blockP_i, prob2, blockP_j)
	
	_sp_hit_counter = 2
	
	return result

func superposition_counter():
	return((randi() % 7) + 3)

func reset_superposition():
	$SideGUI.empty_superposition()
	
############ Helper Functions
	
func switch_blocks(blocki):
	#save position and orientation of blocki and give it to blockj. Change block 
	#to blockj.
	var position = _block._get_block_position()
	var orientation = int(_block.block_rotation)
	_block.queue_free()
	_block = null
	_block = _true_block
	_block._set_block_position(position)
	_block._set_block_rotation(orientation)
	_true_block = null
	pass

func set_orientation(tiles_array):
	## Set map parameters
	var map = TileMap.new()
	map.tile_set = load("res://tilesets/tiles.tres")
	map.cell_size = Vector2(16,16)
	#map.name = "orientation" + String(rotation)
	for tile in tiles_array:
		map.set_cellv(tile, 9)
	
	return map


########################## Http Request Fuctions

func _make_superposition_request(prob):
	var headers = ["Content-Type: application/json"]
	# Add 'Content-Type' header:
	$HTTPRequest.request("https://q-tetris-backend.herokuapp.com/api/determineSuperposition?prob=" + String(prob),  headers, false, HTTPClient.METHOD_GET)
	
func _make_entanglement_request():
	var data_to_send = {}
	var inner_data = {}
	var true_tiles = _block.get_tiles(_block.block_position)
	var rows = []
	for tile in true_tiles:
		if(rows.find(tile[1]) == -1):
			rows.append(tile[1])
	var index = 0 
	for y in rows:
		for x in range(1, board_size.x+1):
			if(true_tiles.find(Vector2(x,y)) == -1):	
				var value
				if($board_tiles.get_cell(x,y) > -1):
					value =1
				else: 
					value = 0
				
				var position_value = {"value": value, "x":x,"y":y }
				inner_data[String(index)] = position_value
				index += 1
	
	data_to_send["grid"] = inner_data
	
	var query = JSON.print(data_to_send)
	#Add 'Content-Type' header:
	var headers = ["Content-Type: application/json"]
	$HTTPRequest.request("https://q-tetris-backend.herokuapp.com/api/flipGrid", headers, false, HTTPClient.METHOD_POST, query)

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	response = JSON.parse(body.get_string_from_utf8())

	if typeof(response.result.result) == TYPE_REAL:
		var server = response.result.result
		temp_server = server
		if int(server) == 0:
			_true_block = temp_block_i
		else:
			_true_block = temp_block_j
			
	else:
		var server = response.result.result
		for server_val in server.values():
			var pos = Vector2(int(server_val["x"]), int(server_val["y"]))
			var value = server_val["value"]
			entanglement[pos] = value
	

