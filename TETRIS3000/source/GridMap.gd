extends GridMap

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

func is_free_cell(cell):
	return (
		0 <= cell.x and cell.x < nb_collumns
		and cell.y >= 0
		and get_cell_item(cell.x, cell.y, cell.z) == INVALID_CELL_ITEM
	)
	
func possible_positions(initial_translations, movement):
	var position
	var test_translations = []
	for i in range(4):
		position = initial_translations[i] + movement
		if is_free_cell(position):
			test_translations.append(position)
		else:
			break
	if test_translations.size() == Tetromino.NB_MINOES:
		return test_translations
	else:
		return []
		
func lock(piece):
	var minoes_over_grid = 0
	for position in piece.get_translations():
		if position.y >= nb_lines:
			minoes_over_grid += 1
		set_cell_item(position.x, position.y, 0, MINO)
	return minoes_over_grid < Tetromino.NB_MINOES

func clear_lines():
	var lines_cleared = 0
	for y in range(nb_lines-1, -1, -1):
		var line_cleared = true
		for x in range(nb_collumns):
			if not get_cell_item(x, y, 0) == MINO:
				line_cleared = false
				break
		if line_cleared:
			for y2 in range(y, nb_lines+2):
				for x in range(nb_collumns):
					var above_cell = get_cell_item(x, y2+1, 0)
					set_cell_item(x, y2, 0, above_cell)
			lines_cleared += 1
			for x in range(nb_collumns):
				exploding_minoes[y][x].emitting = true
				exploding_minoes[y][x].restart()
	return lines_cleared