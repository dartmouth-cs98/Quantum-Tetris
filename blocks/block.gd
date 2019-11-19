tool
extends Node2D

## Block Position
# Vector2 for cell  coordinates on the map
export(Vector2) var block_position = Vector2() setget _set_block_position, \
		_get_block_position
		
## Block Rotation
# codes an integer for one of the tilemaps
export(int, 3) var block_rotation = 0 setget _set_block_rotation

# Current block rotation
var _current_orientation

func _ready():
	_set_block_rotation(block_rotation)
	_set_block_position(block_position)

## _set_block_rotation
# Make the correct child visible
func _set_block_rotation(value):
	block_rotation = int(value)
	if get_child_count() > 0:
		var real_rotation = wrapi(block_rotation, 0, get_child_count())

		for c in get_children():
			c.visible = c.get_index() == real_rotation
			if c.visible:
				# Set the current orientation
				_current_orientation = c

## _set_block_position
# Value should be a Vector2
func _set_block_position(value):
	if get_child_count() > 0:
		if _current_orientation:
			# set position 
			position = value * _current_orientation.cell_size
		else:
			# pick the first orientation
			position = value * get_child(0).cell_size

## _get_block_position
func _get_block_position():
	var result = Vector2()

	if get_child_count() > 0:
		if _current_orientation:
			result = position / _current_orientation.cell_size
		else:
			result = position / get_child(0).cell_size

	return result

## get_rect
# Return a rectangle object containing the top left corner and size in each direction
func get_rect():
	var result = Rect2()
	for c in get_children():
		var rect = c.get_used_rect()
		result.position.x = min(result.position.x, rect.position.x)
		result.position.y = min(result.position.y, rect.position.y)
		result.size.x = max(result.size.x, rect.size.x)
		result.size.y = max(result.size.y, rect.size.y)
	return result

## get_tiles


# take Vector2 position / rotation or take origin and current orientation
func get_tiles(pos = Vector2(0, 0), rot = block_rotation):
	#in case rot != block_rotation, get actual child 
	var real_rotation = wrapi(rot, 0, get_child_count())
	# get an array of the child's cells (their integer id's)
	# get_used_cells: Return an array of all cells containing a tile from the tileset (i.e. a tile index different from -1).
	# the array always has a constant set of values (for z, its [(1, 0), (2, 0), (0, 1), (1, 1)]). 
	# Encodes relative position of each cell from the first, which is denoted (1,0).
	var result = get_child(real_rotation).get_used_cells()
	for i in range(result.size()):
		result[i] += pos
	return result


func get_tile_type(tile):
	return _current_orientation.get_cellv(tile)