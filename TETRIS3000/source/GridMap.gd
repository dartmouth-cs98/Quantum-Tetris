extends GridMap

const Tetromino = preload("res://Tetrominos/Tetromino.gd")
const ExplodingLine = preload("res://ExplodingLine.tscn")

const EMPTY_CELL = -1
const MINO = 0

export (int) var NB_LINES = 20
export (int) var NB_COLLUMNS = 10

var exploding_lines = []

func _ready():
	for y in range(NB_LINES):
		exploding_lines.append(ExplodingLine.instance())
		add_child(exploding_lines[y])
		exploding_lines[y].translation = Vector3(NB_COLLUMNS/2, y, 1)

func clear():
	for position in get_used_cells():
		set_cell_item(position.x, position.y, position.z, EMPTY_CELL)

func is_free_cell(position):
	return (
		0 <= position.x and position.x < NB_COLLUMNS
		and position.y >= 0
		and get_cell_item(position.x, position.y, 0) == GridMap.INVALID_CELL_ITEM
	)
	
func possible_positions(initial_positions, movement):
	var position
	var test_positions = []
	for i in range(4):
		position = initial_positions[i] + movement
		if is_free_cell(position):
			test_positions.append(position)
	if test_positions.size() == Tetromino.NB_MINOES:
		return test_positions
	else:
		return []
		
func lock(piece):
	for position in piece.positions():
		set_cell_item(position.x, position.y, 0, MINO)

func clear_lines():
	var line_cleared
	var lines_cleared = 0
	for y in range(NB_LINES-1, -1, -1):
		line_cleared = true
		for x in range(NB_COLLUMNS):
			if not get_cell_item(x, y, 0) == MINO:
				line_cleared = false
				break
		if line_cleared:
			for y2 in range(y, NB_LINES+2):
				for x in range(NB_COLLUMNS):
					set_cell_item(x, y2, 0, get_cell_item(x, y2+1, 0))
			lines_cleared += 1
			exploding_lines[y].restart()
	return lines_cleared