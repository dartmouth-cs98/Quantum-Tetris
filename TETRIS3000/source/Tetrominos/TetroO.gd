extends "Tetromino.gd"

func turn(direction):
	return false

func assignColor():
	for mino in minoes:
		var material = load("res://Tetrominos/Mino/TetroOMaterial.tres")
		mino.get_node("MinoMesh").set_material_override(material)
		

func _ready():
	assignColor()
	color_mapping = 4