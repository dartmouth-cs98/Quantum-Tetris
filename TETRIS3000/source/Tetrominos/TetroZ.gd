extends "Tetromino.gd"

####################### Setting piece color
func assignColor():
	for mino in minoes:
		var material = load("res://Tetrominos/Mino/TetroZMaterial.tres")
		mino.get_node("MinoMesh").set_material_override(material)

func _ready():
	assignColor()
	color_mapping = 7