tool
extends Node2D

export(Vector2) var block_position = Vector2() setget _set_block_position, \
		_get_block_position
export(int, 3) var block_rotation = 0 setget _set_block_rotation

var _current_orientation

func _ready():
	_set_block_rotation(block_rotation)
	_set_block_position(block_position)

func _set_block_rotation(value):
	block_rotation = value
	if get_child_count() > 0:
		var real_rotation = wrapi(block_rotation, 0, get_child_count())

		for c in get_children():
			c.visible = c.get_index() == real_rotation
			if c.visible:
				_current_orientation = c

func _set_block_position(value):
	if get_child_count() > 0:
		if _current_orientation:
			position = value * _current_orientation.cell_size
		else:
			position = value * get_child(0).cell_size

func _get_block_position():
	var result = Vector2()

	if get_child_count() > 0:
		if _current_orientation:
			result = position / _current_orientation.cell_size
		else:
			result = position / get_child(0).cell_size

	return result

func get_rect():
	var result = Rect2()
	for c in get_children():
		var rect = c.get_used_rect()
		result.position.x = min(result.position.x, rect.position.x)
		result.position.y = min(result.position.y, rect.position.y)
		result.size.x = max(result.size.x, rect.size.x)
		result.size.y = max(result.size.y, rect.size.y)
	return result

func get_tiles(pos = Vector2(0, 0), rot = block_rotation):
	var real_rotation = wrapi(rot, 0, get_child_count())

	var result = get_child(real_rotation).get_used_cells()
	for i in range(result.size()):
		result[i] += pos

	return result

func get_tile_type(tile):
	return _current_orientation.get_cellv(tile)