extends Spatial

const NB_MINOES = 4
const CLOCKWISE = -1
const COUNTERCLOCKWISE = 1
const DROP_MOVEMENT = Vector3(0, -1, 0)

var super_rotation_system = [
    {
        COUNTERCLOCKWISE: [
			Vector3(0, 0, 0),
			Vector3(1, 0, 0),
			Vector3(1, 1, 0),
			Vector3(0, -2, 0),
			Vector3(1, -2, 0)
		],
        CLOCKWISE: [
			Vector3(0, 0, 0),
			Vector3(-1, 0, 0),
			Vector3(-1, 1, 0),
			Vector3(0, -2, 0),
			Vector3(-1, -2, 0)
		],
    },
    {
        COUNTERCLOCKWISE: [
			Vector3(0, 0, 0),
			Vector3(1, 0, 0),
			Vector3(1, -1, 0),
			Vector3(0, 2, 0),
			Vector3(1, 2, 0)
		],
        CLOCKWISE: [
			Vector3(0, 0, 0),
			Vector3(1, 0, 0),
			Vector3(1, -1, 0),
			Vector3(0, 2, 0),
			Vector3(1, 2, 0)
		],
    },
    {
        COUNTERCLOCKWISE: [
			Vector3(0, 0, 0),
			Vector3(-1, 0, 0),
			Vector3(-1, 1, 0),
			Vector3(0, -2, 0),
			Vector3(-1, -2, 0)
		],
        CLOCKWISE: [
			Vector3(0, 0, 0),
			Vector3(1, 0, 0),
			Vector3(1, 1, 0),
			Vector3(0, -2, 0),
			Vector3(1, -2, 0)
		],
    },
    {
        COUNTERCLOCKWISE: [
			Vector3(0, 0, 0),
			Vector3(-1, 0, 0),
			Vector3(-1, -1, 0),
			Vector3(0, 2, 0),
			Vector3(-1, 2, 0)
		],
        CLOCKWISE: [
			Vector3(0, 0, 0),
			Vector3(-1, 0, 0),
			Vector3(-1, -1, 0),
			Vector3(0, -2, 0),
			Vector3(-1, 2, 0)
		]
    }
]

var minoes = []
var orientation = 0
var rotation_point_5_used = false
var rotated_last = false
var grid_map
var lock_delay
var ghost

func _ready():
	for i in range(NB_MINOES):
		minoes.append(get_node("Mino"+str(i)))
	grid_map = get_node("../Matrix/GridMap")
	lock_delay = get_node("../LockDelay")
	ghost = get_node("../Ghost")
	
func set_translations(translations):
	for i in range(NB_MINOES):
		minoes[i].translation = to_local(translations[i])
	
func get_translations():
	var translations = []
	for mino in minoes:
		translations.append(to_global(mino.translation))
	return translations

func move(movement):
	if grid_map.possible_positions(get_translations(), movement):
		translate(movement)
		unlocking()
		rotated_last = false
		move_ghost()
		return true
	else:
		if movement == DROP_MOVEMENT:
			locking()
		return false
	
func turn(direction):
	var translations = get_translations()
	var rotated_translations = [translations[0]]
	var center = translations[0]
	for i in range(1, NB_MINOES):
		var rt = translations[i] - center
		rt = Vector3(-1*direction*rt.y, direction*rt.x, 0)
		rt += center
		rotated_translations.append(rt)
	var movements = super_rotation_system[orientation][direction]
	for i in range(movements.size()):
		if grid_map.possible_positions(rotated_translations, movements[i]):
			orientation = (orientation - direction) % 4
			set_translations(rotated_translations)
			translate(movements[i])
			unlocking()
			rotated_last = true
			if i == 4:
				rotation_point_5_used = true
			move_ghost()
			return true
	return false
	
func move_ghost():
	ghost.set_translations(get_translations())
	while grid_map.possible_positions(ghost.get_translations(), DROP_MOVEMENT):
		ghost.translate(DROP_MOVEMENT)
	
func t_spin():
	return ""
	
func locking():
	if lock_delay.is_stopped():
		lock_delay.start()
	for mino in minoes:
		mino.get_node("LockingMesh").visible = true

func unlocking():
	if not lock_delay.is_stopped():
		lock_delay.start()