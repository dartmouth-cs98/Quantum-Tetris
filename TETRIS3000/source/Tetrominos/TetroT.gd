extends "Tetromino.gd"
    
const T_SLOT = [
	Vector3(-1, 1, 0),
	Vector3(1, 1, 0),
	Vector3(1, -1, 0),
	Vector3(-1, -1, 0)
]
	
func t_spin():
	if rotated_last:
		var center = to_global(minoes[0].translation)
		var a = not grid_map.is_free_cell(center + T_SLOT[orientation])
		var b = not grid_map.is_free_cell(center + T_SLOT[(1+orientation)%4])
		var c = not grid_map.is_free_cell(center + T_SLOT[(3+orientation)%4])
		var d = not grid_map.is_free_cell(center + T_SLOT[(2+orientation)%4])
		if rotation_point_5_used or (a and b and (c or d)):
			return "T-SPIN"
		elif c and d and (a or b):
			return "MINI T-SPIN"
	return ""