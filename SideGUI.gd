extends MarginContainer

#########################   Signals, Constants, Variables   ##########################

########## Scene Nodes

var next_tiles
var super1_map
var super2_map
var super_prob1
var super_prob2

var next_tile1
var next_tile2
var super_piece1
var super_piece2

var weird_switch

##############################   Functions   ###############################

# Called when the node enters the scene tree for the first time.
func _ready():
	next_tiles = get_node("SideMargin/NextPieces/NextTiles")
	super1_map = get_node("SideMargin/Superposition/PieceAndProb/Piece1/Sprite1")
	super2_map = get_node("SideMargin/Superposition/PieceAndProb/Piece2/Sprite2")
	super_prob1 = get_node("SideMargin/Superposition/PieceAndProb/Piece1/Prob1")
	super_prob2 = get_node("SideMargin/Superposition/PieceAndProb/Piece2/Prob2")
	
func change_next(tileP1, tileP2):
	next_tile1 = _replace_child_to_map(true, true, next_tiles, next_tile1, tileP1, Vector2(2,2))
	next_tile2 = _replace_child_to_map(true, true, next_tiles, next_tile2, tileP2, Vector2(2,6))


func set_superposition_data(probability1, tileP1, probability2, tileP2):
	## Set text for labels
	super_prob1.text = String(probability1)
	super_prob2.text = String(probability2)
	
	## replace tiles
	super_piece1 = _replace_child_to_map(false, true, super1_map, super_piece1, tileP1, Vector2(2,2))
	super_piece2 = _replace_child_to_map(false, true, super2_map, super_piece2, tileP2, Vector2(2,6))
	
	weird_switch = true
	
func empty_superposition():
	## Set text for labels
	super_prob1.text = ""
	super_prob2.text = ""
	super_piece1 = _replace_child_to_map(true, false, super1_map, super_piece1, Node, null)
	super_piece2 = _replace_child_to_map(true, false, super2_map, super_piece2, Node, null)
#### FOR TESTING	
func _replace_child_to_map(replace, add, node, child, childP, position):
	if childP.get_class()=="PackedScene":
		if replace:
			node.remove_child(child)
			if child != null:
				child.queue_free()
		if add:	
			child = childP.instance()
			node.add_child(child)
			child._set_block_position(position)
	else: 
		if replace:
			node.remove_child(child)
			if weird_switch:
				#print("weird switch")
				child.queue_free()
				child = null
				weird_switch = false
		if add:
			child = childP.duplicate()
			#print(String(child.get_tiles()))
			node.add_child(child)
			child._set_block_position(position)
			
	return child

