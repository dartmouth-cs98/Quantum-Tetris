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

####################### Endpoint Functions

# Called when the node enters the scene tree for the first time.
func _ready():
	next_tiles = get_node("SideMargin/NextPieces/NextTiles")
	super1_map = get_node("SideMargin/Superposition/PieceAndProb/Piece1/Sprite1")
	super2_map = get_node("SideMargin/Superposition/PieceAndProb/Piece2/Sprite2")
	
	super_prob1 = get_node("SideMargin/Superposition/PieceAndProb/Piece1/Prob1")
	super_prob2 = get_node("SideMargin/Superposition/PieceAndProb/Piece2/Prob2")
	
func change_next(tileP1, tileP2):
	next_tiles.clear()
	
	draw_next_scenes(next_tiles, tileP1, Vector2(2,2))
	draw_next_scenes(next_tiles, tileP2, Vector2(2,6))

func set_superposition_data(probability1, tileP1, probability2, tileP2):
	## Set text for labels
	super_prob1.text = String(probability1)
	super_prob2.text = String(probability2)
	
	draw_next_scenes(super1_map, tileP1, Vector2(2,2))
	draw_next_scenes(super2_map, tileP2, Vector2(2,2))
	
func empty_superposition():
	## Set text for labels
	super_prob1.text = ""
	super_prob2.text = ""
	super1_map.clear()
	super2_map.clear()

####################### Helper Functions

func draw_next_scenes(map, pieceP, pos):
	if pieceP.get_class()=="PackedScene":
		var piece = pieceP.instance()
		map.add_child(piece)
		var some_tile = piece.get_tiles()[0]
		var type = piece.get_tile_type(some_tile)
		map.remove_child(piece)
		for tile in piece.get_tiles():
			map.set_cellv(tile+pos, type)#piece.get_tile_type(tile))
	else:
		map.add_child(pieceP)
		var some_tile = pieceP.get_tiles()[0]
		var type = pieceP.get_tile_type(some_tile)
		map.remove_child(pieceP)
		for tile in pieceP.get_tiles():
			map.set_cellv(tile+pos, pieceP.get_tile_type(tile))
