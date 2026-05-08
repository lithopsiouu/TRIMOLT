extends Node

# TODO: Add branchiness variable (control "marble bag/shuffle bag" likelihood of branching paths)
# TODO: Add roominess variable (control room + room sizes)
# TODO: Add height + depth variables
# TODO: Add spawn nodes for enemies, rewards, and props
# TODO: Consolidation and merges
# TODO: Path conflict resolution (intersecting nodes)


@onready var level_holder: Node3D = $"../LevelHolder"

var last_tile: Node = null
var max_level_length: int = 20
var max_branch_length: int = 3
var end_branches: Array[Node3D] = []

const TILE_START = preload("res://Scenes/Map Generation Tiles/Test Tiles/tile_start.tscn")
const TILE_END = preload("res://Scenes/Map Generation Tiles/Test Tiles/tile_end.tscn")
const TILE_TRUE_END = preload("res://Scenes/Map Generation Tiles/Test Tiles/tile_true_end.tscn")

var test_tiles_path: String = "res://Scenes/Map Generation Tiles/Test Tiles/tile_%s.tscn"
var all_test_tiles: Array = [
	"straight",
	"split",
	"straight_room",
	"uppy",
	"downy",
]

func _get_test_node(array_index) -> PackedScene:
	var test_node:PackedScene = null
	if array_index < all_test_tiles.size():
		test_node = load(test_tiles_path % all_test_tiles[array_index])
	return test_node

# Called when the node enters the scene tree for the first time.
func _ready() -> void: # main tiles here
	var start = TILE_START.instantiate()
	var true_end = TILE_TRUE_END.instantiate()
	
	if level_holder.ready: level_holder.add_child(start)
	last_tile = level_holder.get_child(0)
	
	for i in range(max_level_length):
		#_add_test_tile(1)
		_add_test_tile(randi_range(0, (all_test_tiles.size() -1)))
		
	level_holder.add_child(true_end)
	_connect_tile(true_end)
	
	for branch in end_branches.size(): # branching tiles here
		var rand_branch_length: int = randi_range(1, max_branch_length)
		last_tile = end_branches[branch]
		for tile in rand_branch_length:
			var rand_tile: int = randi_range(0, (all_test_tiles.size() -1))
			_add_test_tile_at_end(4, last_tile, true) #tile selection
		
		_end_branch() #ends each branch

## Create an [b]end[/b] tile at last_tile or a specific [param end_node] [Node3D].
## Use [param new_last_tile] if passing a [b]tile[/b] and want to set the [param last_tile].
func _end_branch(end_node: Node3D = null, new_last_tile = false) -> void:
	var branch_end = TILE_END.instantiate()
	level_holder.add_child(branch_end)
	if end_node == null:
		_connect_tile_at_end(branch_end, last_tile, new_last_tile)
	else:
		_connect_tile_at_end(branch_end, end_node, new_last_tile)

## [param array_index] grabs a tile at the specified index of the array.[br]
## [param last_tile] is set to the new node of [param array_index]
## @experimental: This is a test function.
func _add_test_tile(array_index: int):#add array field in non-test func
	var node: Node3D = _get_test_node(array_index).instantiate()
	level_holder.add_child(node)
	_connect_tile(node)
	last_tile = node

## [param array_index] grabs a tile at the specified index of the array.[br]
## [param target_node] is the [b]end[/b] node that the new tile will be oriented to using
## _connect_tile_at_end().[br]
## [param set_last_tile] sets [param last_tile] the new node of [param array_index]. [b]MUST USE A TILE[/b]
## @experimental: This is a test function.
func _add_test_tile_at_end(array_index: int, target_node: Node3D, set_last_tile:bool = false): #TODO merge _connect_tile here
	var tile: Node3D = _get_test_node(array_index).instantiate()
	level_holder.add_child(tile)
	_connect_tile_at_end(tile, target_node, set_last_tile)

## Transforms [param target_node] to orientation of [param last_tile].[br]
## Appends unused ends to array [param end_branches] for later branching.
## @experimental: This is an unfinished function.
func _connect_tile(target_node: Node3D): #TODO add scalability for more than 2 ends, maybe by collection and addition into an array
	var lastTile: Node3D = last_tile.find_child("End")
	if lastTile == null:
		var randTile = randi_range(1,2)
		lastTile = last_tile.find_child("End" + str(randTile))
		if (randTile/2) == 1:
			end_branches.append(last_tile.find_child("End1"))
		else:
			end_branches.append(last_tile.find_child("End2"))
	target_node.global_transform = lastTile.global_transform

## Transforms a [b]tile[/b] [param target_node] to the orientation of an [param end_node].[br]
## Use [param set_last_tile] to set the [param last_tile].
func _connect_tile_at_end(target_node: Node3D, end_node: Node3D, set_last_tile = false):
	if end_node.find_child("End") != null:
		target_node.global_transform = end_node.find_child("End").global_transform
	else:
		target_node.global_transform = end_node.global_transform
	
	if set_last_tile:
		last_tile = target_node
