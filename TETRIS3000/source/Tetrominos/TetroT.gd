extends "Tetromino.gd"
    
const T_SLOT = [
	Vector3(-1, 1, 0),
	Vector3(1, 1, 0),
	Vector3(1, -1, 0),
	Vector3(-1, -1, 0)
]

func rotate(direction):
	var rotation_point = .rotate(direction)
	if rotation_point and t_spin != T_SPIN:
		var center = to_global(minoes[0].translation)
		var a = not grid_map.is_free_cell(center + T_SLOT[orientation])
		var b = not grid_map.is_free_cell(center + T_SLOT[(1+orientation)%4])
		var c = not grid_map.is_free_cell(center + T_SLOT[(2+orientation)%4])
		var d = not grid_map.is_free_cell(center + T_SLOT[(3+orientation)%4])
		if a and b and (c or d):
			t_spin = T_SPIN
		elif c and d and (a or b):
			if rotation_point == 5:
				t_spin = T_SPIN
			else:
				t_spin = MINI_T_SPIN
	return rotation_point