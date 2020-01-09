extends "Tetromino.gd"

const CLOCKWISE = -1
const COUNTERCLOCKWISE = 1
const SUPER_ROTATION_SYSTEM = [
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