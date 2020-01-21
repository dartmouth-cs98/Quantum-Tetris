extends Spatial
#################################  Notes  ################################# 
### Every piece is initialized with these functions. 
### During initialization (_ready) the pieces Minos are stored in the Minos variable,
##### subsequent functions act on the list of Minos. 
### The ghost piece is just one piece that is translated to be under the current piece when it is put on the board.
### Mino 0 is always at the center of the piece (at origin). This is important for turning. 
#########################  Constants and Variables  ######################### 
const NB_MINOES = 4
const CLOCKWISE = -1
const COUNTERCLOCKWISE = 1
const DROP_MOVEMENT = Vector3(0, -1, 0)

#Encodes rotation vectors for each piece. Overloaded by each pieces indiviual variables.
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

# Tracks orientation - set by indices of the above list 
var orientation = 0
var rotation_point_5_used = false
# tracks whether the last movement was a rotation or tranlsation.
var rotated_last = false

###### Variables to Control Scene Nodes 
var minoes = []
var grid_map
var lock_delay

# ghost piece
var ghost

# Boolean
# True -> between the 2 superimposed pieces, this is the fake one.
var is_fake


#########################  Functions  ######################### 

### _ready - assign all nodes to associated variables
func _ready():
	for i in range(NB_MINOES):
		minoes.append(get_node("Mino"+str(i)))
	grid_map = get_node("../Matrix/GridMap")
	lock_delay = get_node("../LockDelay")
	ghost = get_node("../Ghost")
	
### set_translations
## Input: A set of vector3's in global space (the scene space)
## Function: Turns global locations into local space locations using to_local. Then 
# sets the translation (position of the piece). Find translation under transform property 
# of spacial node.
## Other: This is an overwritten function - now handles all of the piece's blocks. 
func set_translations(translations):
	for i in range(NB_MINOES):
		minoes[i].translation = to_local(translations[i])

### get_translations	
## Function: Ouputs each blocks position in global space. Uses to_global to get these coordinates
func get_translations():
	var translations = []
	for mino in minoes:
		translations.append(to_global(mino.translation))
	return translations

### move
## Input: Vector, see movements in main.
## Function: Translate a piece. 
func move(movement):
	#possible 
	if grid_map.possible_positions(get_translations(), movement):
		translate(movement)
		unlocking()
		rotated_last = false
		move_ghost()
		return true
	# the move is not possible
	else:
		
		## i.e. if the move is not possible AND that movement is downwards
		if movement == DROP_MOVEMENT:
			
			if !is_fake:
				# Begin locking the piece!
				locking()
				
			else:
				get_parent().remove_child(self)
			
			
		return false
### turn
## Input: Direction is either CLOCKWISE or COUNTERCLOCKWISE
func turn(direction):
	# Get current positions
	var translations = get_translations()
	var rotated_translations = [translations[0]]
	var center = translations[0]
	# Check if rotation is possible
	for i in range(1, NB_MINOES):
		var rt = translations[i] - center
		rt = Vector3(-1*direction*rt.y, direction*rt.x, 0)
		rt += center
		rotated_translations.append(rt)
	# Superposition list: split by orientations then turn of direction.
	var movements = super_rotation_system[orientation][direction]
	for i in range(movements.size()):
		if grid_map.possible_positions(rotated_translations, movements[i]):
			#Set new orientation
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


### move_ghost
func move_ghost():
	# ghost is the "Ghost" scene
	# See res://Tetrominos/Ghost.tscn
	ghost.set_translations(get_translations())
	# While possible, keep dropping piece. 
	while grid_map.possible_positions(ghost.get_translations(), DROP_MOVEMENT):
		ghost.translate(DROP_MOVEMENT)
	
# Returns an empty string.
# Used effectively as a boolean
# Evaluates to true!
func t_spin():
	return ""
	
	
# Starts locking timer
func locking():
	
	if lock_delay.is_stopped():
		lock_delay.start()
		
	
	for mino in minoes:
		mino.get_node("LockingMesh").visible = true

func unlocking():
	if not lock_delay.is_stopped():
		lock_delay.start()
		
		

func set_fake():
	
	is_fake = true