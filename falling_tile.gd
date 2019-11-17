extends Sprite

################################# Notes ################################ 

######## About TileMaps and Sets
##### TileMaps use TileSets to create a grid
##### TileSets contains a list of tiles, each consisting of a sprite and optional collision shapes.
### Tiles are referenced by a unique integer ID. Any cell without a tile has a value of -1


##### Notes
### Falling tile is the current tile on the screen, it is instanced in board.
### VisibilityNotifier2D: detects when the node is visible on screen.
# VisibilityNotifier2D has 

############################ Variables and Constants ##########################

const SPIN_SPEED = deg2rad(500)
var fall_speed = 400

############################ Functions ##########################

## set_tile
func set_tile(tilemap, tile):
	## Finds position
	#get_cell returns the tile index of the given cell
	#cell_size 
	position = (tile * tilemap.cell_size) + (tilemap.cell_size / 2)
	# Sets size and position 
	$VisibilityNotifier2D.rect.position = -(tilemap.cell_size / 2)
	$VisibilityNotifier2D.rect.size = tilemap.cell_size

	var tile_index = tilemap.get_cellv(tile)
	texture = tilemap.tile_set.tile_get_texture(tile_index)
	region_rect = tilemap.tile_set.tile_get_region(tile_index)

## Process function
# Every time step, sets the new position of the function
# What is rotation??
func _process(delta):
	position += Vector2(0, fall_speed) * delta
	rotation += SPIN_SPEED * delta

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	