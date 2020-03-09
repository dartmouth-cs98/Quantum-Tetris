extends "Tetromino.gd"

####################### Setting piece color

func assignColor():
	for mino in minoes:
		var material = load("res://Tetrominos/Mino/TetroIMaterial.tres")
		mino.get_node("MinoMesh").set_material_override(material)

func _ready():
	assignColor()
	color_mapping = 1

func _init():
	assignColor()
	super_rotation_system = [
	    {
	        COUNTERCLOCKWISE: [
				Vector3(0, -1, 0),
				Vector3(-1, -1, 0),
				Vector3(2, -1, 0),
				Vector3(-1, 1, 0),
				Vector3(2, -2, 0)
			],
	        CLOCKWISE: [
				Vector3(1, 0, 0),
				Vector3(-1, 0, 0),
				Vector3(2, 0, 0),
				Vector3(-1, -1, 0),
				Vector3(2, 2, 0)
			],
	    },
	    {
	        COUNTERCLOCKWISE: [
				Vector3(-1, 0, 0),
				Vector3(1, 0, 0),
				Vector3(-2, 0, 0),
				Vector3(1, 1, 0),
				Vector3(-2, -2, 0)
			],
	        CLOCKWISE: [
				Vector3(0, -1, 0),
				Vector3(-1, -1, 0),
				Vector3(2, -1, 0),
				Vector3(-1, 1, 0),
				Vector3(2, -2, 0)
			],
	    },
	    {
	        COUNTERCLOCKWISE: [
				Vector3(0, 1, 0),
				Vector3(1, 1, 0),
				Vector3(-2, 1, 0),
				Vector3(1, -1, 0),
				Vector3(-2, 2, 0)
			],
	        CLOCKWISE: [
				Vector3(-1, 0, 0),
				Vector3(1, 0, 0),
				Vector3(-2, 0, 0),
				Vector3(1, 1, 0),
				Vector3(-2, -2, 0)
			],
	    },
	    {
	        COUNTERCLOCKWISE: [
				Vector3(1, 0, 0),
				Vector3(-1, 0, 0),
				Vector3(2, 0, 0),
				Vector3(-1, -1, 0),
				Vector3(2, 2, 0)
			],
	        CLOCKWISE: [
				Vector3(0, 1, 0),
				Vector3(1, 1, 0),
				Vector3(-2, 1, 0),
				Vector3(1, -1, 0),
				Vector3(-2, 2, 0)
			],
	    },
	]