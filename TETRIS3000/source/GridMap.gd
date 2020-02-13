extends GridMap
#################################  Notes  #################################

const Tetromino = preload("res://Tetrominos/Tetromino.gd")
const ExplodingMino = preload("res://Tetrominos/Mino/ExplodingMino.tscn")

const EMPTY_CELL = -1
const MINO = 0

var exploding_minoes = []
var nb_collumns
var nb_lines

func _ready():
	nb_collumns = int(get_parent().scale.x)
	nb_lines = int(get_parent().scale.y)
	for y in range(nb_lines):
		exploding_minoes.append([])
		for x in range(nb_collumns):
			exploding_minoes[y].append(ExplodingMino.instance())
			add_child(exploding_minoes[y][x])
			exploding_minoes[y][x].translation = Vector3(x, y, 0)

func clear():
	for used_cell in get_used_cells():
		set_cell_item(used_cell.x, used_cell.y, used_cell.z, EMPTY_CELL)

### is_free_cell
## Input: A Vector 
func is_free_cell(cell, entanglement): #3D Vector
	
	# The two boundaries restricting the piece's lateral movement
	var left_bound = 0
	var right_bound = nb_collumns
	
	if( entanglement < 0 ): right_bound = 5
	elif( entanglement > 0 ): left_bound = 5
	
	return (
	
		# Right here is where you set the bounds for entanglement!!
		# Within grid columns (not at side edge)
		left_bound <= cell.x and cell.x < right_bound
		# Above the bottom
		and cell.y >= 0
		# The cell is empty - built in GridMesh Function
		and get_cell_item(cell.x, cell.y, cell.z) == INVALID_CELL_ITEM
	)
### possible_positions
## Function: Check if position is available. 
func possible_positions(initial_translations, movement, entanglement): # Set of vectors with cur position (global) and movement vector 
	var position
	var test_translations = []
	
	# For each possible orientation,
	for i in range(4):
		position = initial_translations[i] + movement
		
		# Checks here whether the move is possible
		if is_free_cell(position, entanglement):
			test_translations.append(position)
		# one of the cells is full
		else:
			break
	# if test_translations has the same size, then no break so all cells are empty.
	if test_translations.size() == Tetromino.NB_MINOES:
		return test_translations
	else:
		return []

### lock
## Function: Transfer a pieces minos to the gridmap. 
func lock(piece):
	var minoes_over_grid = 0
	for position in piece.get_translations():
		if position.y >= nb_lines:
			minoes_over_grid += 1
			
		# This function seems to lock the piece into the grid
		# However, it appears to affect all pieces in the grid
		set_cell_item(position.x, position.y, 0, MINO)
	return minoes_over_grid < Tetromino.NB_MINOES


### clear_lines
func clear_lines():
	var lines_cleared = 0
	for y in range(nb_lines-1, -1, -1):
		# Assume the line is full.
		var line_cleared = true
		# If there is an empty space, move to the next line.
		for x in range(nb_collumns):
			if not get_cell_item(x, y, 0) == MINO:
				line_cleared = false
				break
		# If the line is clear, move every block down one.
		if line_cleared:
			for y2 in range(y, nb_lines+2):
				for x in range(nb_collumns):
					var above_cell = get_cell_item(x, y2+1, 0)
					set_cell_item(x, y2, 0, above_cell)
			lines_cleared += 1
			# Use hidden exploding minos for animation.
			for x in range(nb_collumns):
				exploding_minoes[y][x].emitting = true
				exploding_minoes[y][x].restart()
	return lines_cleared
