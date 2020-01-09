extends Node2D

onready var shape_blocks = [$Block, $Block2, $Block3, $Block4]
onready var shape_blocks_positions = [] setget update_shape_block_positions, get_shape_block_positions

	
func _ready():
	update_shape_block_positions(null)

func update_shape_block_positions(null):
	shape_blocks_positions = []
	for i in shape_blocks:
		shape_blocks_positions.append( i.global_position /16 )

func get_shape_block_positions():
	update_shape_block_positions(null)
	return shape_blocks_positions
