extends "Tetromino.gd"

####################### Setting piece color
func assignColor():
	for mino in minoes:
		var material = load("res://Tetrominos/Mino/TetroTMaterial.tres")
		mino.get_node("MinoMesh").set_material_override(material)

func _ready():
	assignColor()
	color_mapping = 6
   
const T_SLOT = [
	Vector3(-1, 1, 0),
	Vector3(1, 1, 0),
	Vector3(1, -1, 0),
	Vector3(-1, -1, 0)
]
	
func t_spin():
	if rotated_last:
		var center = to_global(minoes[0].translation)
		var a = not grid_map.is_free_cell(center + T_SLOT[orientation], 0)
		var b = not grid_map.is_free_cell(center + T_SLOT[(1+orientation)%4], 0)
		var c = not grid_map.is_free_cell(center + T_SLOT[(3+orientation)%4], 0)
		var d = not grid_map.is_free_cell(center + T_SLOT[(2+orientation)%4], 0)
		if rotation_point_5_used or (a and b and (c or d)):
			return "T-SPIN"
		elif c and d and (a or b):
			return "MINI T-SPIN"
	return ""