extends Spatial
#################################  Notes  ################################# 
### Every piece is initialized with these functions. 
### During initialization (_ready) the pieces Minos are stored in the Minos variable,
##### subsequent functions act on the list of Minos. 
### The ghost piece is just one piece that is translated to be under the current piece when it is put on the board.
### Mino 0 is always at the center of the piece (at origin). This is important for turning. 
###############################  Constants and Variables  ############################### 
const NB_MINOES = 4
const CLOCKWISE = -1
const COUNTERCLOCKWISE = 1
const DROP_MOVEMENT = Vector3(0, -1, 0)


# "Orientation" indexes into one of the 4 possible orientations,
# and then "direction" indexes into either CLOCKWISE or COUNTERCLOCKWISE.
# Finally, each vector represents a DIFFERENT WAY to rotate the piece
# When the player tries to turn the piece, each vector is used sequentially to attempt to turn the piece
# The fifth way to rotate is only triggered through T-SPIN
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
# tracks whether the last movement was a rotation - tracks T spin.
var rotated_last = false

###### Variables to Control Scene Nodes 
var minoes = []
var grid_map
var lock_delay

# ghost pieces
var ghost: Node
var ghostB: Node	# For a real entangled piece
var ghost_fake: Node
var ghost_fakeB: Node


# Boolean
# True -> between the 2 superimposed pieces, this is the fake one.
var is_fake: bool = false
var is_locked: bool = false

# int
# 0 -> this piece is not entangled
# negative -> this piece is entangled into the left side of the grid
# positive -> right side of the grid

var color_mapping = 0
var entanglement: int = 0
var first_hit = true
var TESTING = false

signal switch 
signal no_switch
signal lock

#####################################  Functions  ##################################### 


### _ready - assign all nodes to associated variables
func _ready():
	for i in range(NB_MINOES):
		minoes.append(get_node("Mino"+str(i)))
	grid_map = get_node("../Matrix/GridMap")
	lock_delay = get_node("../LockDelay")
	ghost = get_node("../Ghost")
	ghostB = get_node("../GhostB")
	ghost_fake = get_node("../FakeGhost")
	ghost_fakeB = get_node("../FakeGhostB")
	
	

####################### Controlling Piece
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
func move(movement: Vector3) -> bool:
	
	# If the move is possible, 
	# This is where you have to stop entangled pieces from moving through the middle-axis!
	if grid_map.possible_positions(get_translations(), movement, entanglement):
		translate(movement)
		unlocking()
		rotated_last = false
		
		# If the piece still has at least 3 spaces below it, 
		if (grid_map.possible_positions(get_translations(), Vector3(0, -3, 0), entanglement)):
			move_ghost() # Keep the ghost visible
		
		# If it doesn't have that space, 
		else: 
			move_ghost(true) # Make the ghost disappear
		
		return true
		
	# the move is not possible
	else:
		
		## i.e. if the move is not possible AND that movement is downwards
		if movement == DROP_MOVEMENT:
			# If this piece is real
			if entanglement > 0 and first_hit:
				TESTING = true
				print("switching!")
				emit_signal("switch")
			elif entanglement<0 and first_hit:
				TESTING = true
				emit_signal("no_switch")
			
			if TESTING:
				pass
			
				
			# Begin locking the piece!
			locking()
			if !is_fake:
				emit_signal("lock")
				
			else:
				
				# ...and removes itself from the scene-tree!
				# (along with its ghost)
				if(entanglement >= 0):
					ghost_fake.visible = false
				else:
					ghost_fakeB.visible = false
					
				
		return false
		
func process_switch():
	
	first_hit = false
	is_fake = !is_fake
	
func process_no_switch():
	
	first_hit = false

### turn
## Input: Direction is either CLOCKWISE or COUNTERCLOCKWISE
func turn(direction: int):
	# Get current positions
	var translations = get_translations()
	var rotated_translations = [translations[0]]
	var center = translations[0]
	
	# Check if rotation is possible
	for i in range(1, NB_MINOES):
		
		# Logic for moving the cubes correctly for a rotation
		var rt = translations[i] - center
		rt = Vector3(-1*direction*rt.y, direction*rt.x, 0)
		rt += center
		rotated_translations.append(rt)
		
	# Superposition list: split by orientations then turn of direction.
	var movements = super_rotation_system[orientation][direction]
	
	# Only loops until success
	for i in range(movements.size()):
		if grid_map.possible_positions(rotated_translations, movements[i], 0):
			
			#Set new orientation
			# Rotate the piece's position by either +1 or -1
			orientation = (orientation - direction) % 4
			
			# Actually moves the piece
			set_translations(rotated_translations)
			
			# Moves the piece back in bounds if it's rotated out of bounds!
			translate(movements[i])
			
			# If the piece is still somehow in an illegal position,
			# (This happens in the center with entanglement)
			if grid_map.possible_positions(rotated_translations, movements[i], 0):
				if( entanglement < 0 && grid_map.possible_positions(rotated_translations, Vector3(-1, 0, 0), 0)):
					# Kick the piece to the left if it's entangled left 
					# (and if it can be kicked left)
					translate(Vector3(-1, 0, 0))
				elif( entanglement > 0 && grid_map.possible_positions(rotated_translations, Vector3(1, 0, 0), 0)):
					# Kick the piece to the right if it's entangled right
					# (and if it can be kicked right)
					translate(Vector3(1, 0, 0))
					
			
			# Now piece doesn't infinitely spin
			# unlocking()
			rotated_last = true
			if i == 4:
				rotation_point_5_used = true
			move_ghost()
			return true
	return false
	
####################### Ghost
### move_ghost
func move_ghost(var vanish: bool = false):
	
	var this_ghost: Node = get_ghost()
	
	
	if( vanish ):
		this_ghost.visible = false
		
		# Vanishes the superimposed counterpart as well
		if( this_ghost == ghost_fake ): ghost.visible = false
		elif( this_ghost == ghost ): ghost_fake.visible = false
		elif( this_ghost == ghost_fakeB ): ghostB.visible = false
		elif( this_ghost == ghostB ): ghost_fakeB.visible = false
			
	else: 
		# Makes the ghost visible again if the piece somehow gets space under it again
		this_ghost.visible = true
		
		# Superimposed counterpart also reappears
		if( this_ghost == ghost_fake ): ghost.visible = true
		elif( this_ghost == ghost_fakeB ): ghostB.visible = true
		
		
		
		
		
	# this_ghost is the "Ghost" scene
	# See res://Tetrominos/Ghost.tscn
	this_ghost.set_translations(get_translations())
	# While possible, keep dropping piece. 
	while grid_map.possible_positions(this_ghost.get_translations(), DROP_MOVEMENT, entanglement):
		this_ghost.translate(DROP_MOVEMENT)
		
		
func get_ghost() -> Node:
	
	var this_ghost: Node
	
	if (!is_fake):
		if (entanglement >= 0):
			this_ghost = ghost
		else:
			this_ghost = ghostB
	else:
		if (entanglement >= 0):
			this_ghost = ghost_fake
		else:
			this_ghost = ghost_fakeB
			
	return this_ghost
	
		
		
####################### Scoring
# Returns an empty string.
# Used effectively as a boolean
# Evaluates to true!
func t_spin():
	return ""

####################### Locking 
	
# Starts locking timer
func locking():
	
	# become invisible when touching down if fake
	if( is_fake ): 
		self.visible = false
		get_ghost().visible = false
		remove_child(self)
	
	if lock_delay.is_stopped():
		lock_delay.start()
	for mino in minoes:
		mino.get_node("LockingMesh").visible = true

func unlocking():
	if not lock_delay.is_stopped():
		lock_delay.start()
		
		
# Identifies the piece as locked
func lock(): 
	is_locked = true;
####################### Superposition Functions
func set_fake():
	is_fake = true

func set_real():
	is_fake = false
	
func get_is_fake() -> bool:
	return is_fake
	
	
####################### Entanglement functions

func entangle(entangle_int: int): 
	
	entanglement = entangle_int
	
	
func disentangle():
	
	get_ghost().visible = false
	
	entanglement = 0
	
	get_ghost().visible = true

func get_color_map(): 
	return color_mapping
	
func connect_neighbors(neighbors):
	#Connect within itself
	connect("switch", self, "process_switch")
	connect("no_switch", self, "process_no_switch")
	#Connect to each neighbor
	for neighbor in neighbors:
		connect("switch",neighbor,"process_switch")
		connect("no_switch", neighbor, "process_no_switch")
	
	
	
	