extends Sprite

const FALL_SPEED = 400
const SPIN_SPEED = deg2rad(500)

func set_tile(tilemap, tile):
	position = (tile * tilemap.cell_size) + (tilemap.cell_size / 2)
	$VisibilityNotifier2D.rect.position = -(tilemap.cell_size / 2)
	$VisibilityNotifier2D.rect.size = tilemap.cell_size

	var tile_index = tilemap.get_cellv(tile)
	texture = tilemap.tile_set.tile_get_texture(tile_index)
	region_rect = tilemap.tile_set.tile_get_region(tile_index)

func _process(delta):
	position += Vector2(0, FALL_SPEED) * delta
	rotation += SPIN_SPEED * delta

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()