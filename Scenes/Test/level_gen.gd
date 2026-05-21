extends Node

# TODO: Add branchiness variable (control "marble bag/shuffle bag" likelihood of branching paths)
# TODO: Add roominess variable (control room + room sizes)
# TODO: Add height + depth variables
# TODO: Add spawn nodes for enemies, rewards, and props
# TODO: Path conflict resolution (intersecting nodes)


@onready var level_holder: Node3D = $"../LevelHolder"
@onready var collision_check: ShapeCast3D = $"../IntersectionCheck"
@onready var err_point: MeshInstance3D = $"../Point"
@onready var pos_point: MeshInstance3D = $"../PointGreen"

var last_tile: Node = null ## Last generated tile/[param end_node]
var max_level_length: int = 20 ## Maximum amount of tiles for main tree length
var max_branch_length: int = 3 ## Maximum amount of tiles for tree branch length
var end_nodes: Array[Node3D] = [] ## Container for end nodes of main tree used for branch generation

var gen_done = false ## flag if generation is complete

const TILE_START = preload("res://Scenes/Map Generation Tiles/Test Tiles/tile_start.tscn")
const TILE_END = preload("res://Scenes/Map Generation Tiles/Test Tiles/tile_end.tscn")
const TILE_TRUE_END = preload("res://Scenes/Map Generation Tiles/Test Tiles/tile_true_end.tscn")

## String that holds the path containing test tiles
var test_tiles_path: String = "res://Scenes/Map Generation Tiles/Test Tiles/tile_%s.tscn"
var all_test_tiles: Array = [ ## All test tiles for map generation
	"straight",
	"split",
	"straight_room",
	"uppy",
	"downy",
	"X_split",
	"Y_room",
	"perpen_split",
]

func _get_test_node_name(array_value: String) -> PackedScene:
	var test_node:PackedScene = null
	if all_test_tiles.has(array_value):
		test_node = load(test_tiles_path % array_value)
	return test_node

func _get_test_node(array_index) -> PackedScene:
	var test_node:PackedScene = null
	if array_index < all_test_tiles.size():
		test_node = load(test_tiles_path % all_test_tiles[array_index])
	return test_node

# Called when the node enters the scene tree for the first time.
func _ready() -> void: # main tiles here
	pass#_generate_level()

func _process(delta: float) -> void:
	if gen_done == false:
		_generate_level()

func _generate_level() -> void:
	var start = TILE_START.instantiate()
	var true_end = TILE_TRUE_END.instantiate()
	
	level_holder.add_child(start)
	last_tile = level_holder.get_child(0)
	
	for i in range(max_level_length):
		#_add_test_tile(1)
		var rand_tile = all_test_tiles.pick_random()
		_check_tile_space()
		_add_test_tile(rand_tile, true)
		
	level_holder.add_child(true_end)
	_new_connect_tile(true_end)
	#connect_tile(true_end)
	
	if end_nodes.size() > 0:
		_make_branches()
	
	gen_done = true

## Orient a ShapeCast3D cylinder to [param last_tile]
func _check_tile_space() -> void:
	collision_check.global_transform = last_tile.global_transform
	var exception = null
	if last_tile.find_child("Tile") != null:
		exception = last_tile.find_child("Tile").find_child("StaticBody3D")
		collision_check.add_exception(exception)
	collision_check.force_update_transform()
	collision_check.force_shapecast_update()
	var newpoint := pos_point.duplicate()
	level_holder.add_child(newpoint)
	newpoint.global_position = collision_check.global_position
	
	for result in collision_check.get_collision_count():
		var point: Node3D = err_point.duplicate()
		level_holder.add_child(point)
		#print(collision_check.get_collision_point(result))
		point.global_position = collision_check.get_collision_point(result)
		DebugDraw3D.draw_line(point.global_position, newpoint.global_position, Color.PURPLE)
		
	
	#return collision_check.is_colliding()
	#print(collision_check.global_position)

## Create tree branches from a collection of end tiles
func _make_branches() -> void:
	var test_tiles_no_branch = all_test_tiles.duplicate()
	test_tiles_no_branch.erase("split")
	test_tiles_no_branch.erase("X_split")
	test_tiles_no_branch.erase("Y_room")
	test_tiles_no_branch.erase("perpen_split")
	
	for branch in end_nodes.size(): # branching tiles here
		var rand_branch_length: int = 3#randi_range(1, max_branch_length)
		last_tile = end_nodes[branch]
		for tile in rand_branch_length:
			var rand_tile: String = test_tiles_no_branch.pick_random()
			_check_tile_space()
			await get_tree().create_timer(0.1).timeout
			_add_test_tile(rand_tile, true) #tile selection
		
		_end_branch() #ends each branch

## Create an [b]end[/b] tile at last_tile or a specific [param end_node] [Node3D].
## Use [param new_last_tile] if passing a [b]tile[/b] and want to set the [param last_tile].
func _end_branch(new_last_tile = false) -> void:
	var branch_end = TILE_END.instantiate()
	level_holder.add_child(branch_end)
	_new_connect_tile(branch_end, new_last_tile)

## [param array_index] grabs a tile at the specified index of the array.[br]
## [param target_node] is the [b]end[/b] node that the new tile will be oriented to using
## _connect_tile_at_end().[br]
## [param set_last_tile] sets [param last_tile] the new node of [param array_index]. [b]MUST USE A TILE[/b]
## @experimental: This is a test function.
func _add_test_tile(array_value: String, set_last_tile:bool = false): #TODO merge _connect_tile here
	var tile: Node3D = _get_test_node_name(array_value).instantiate()
	level_holder.add_child(tile)
	_new_connect_tile(tile, set_last_tile)

## Transforms a [b]tile[/b] [param target_node] to the orientation of [param last_tile].[br]
## Use [param set_last_tile] to set the [param last_tile].
func _new_connect_tile(target_tile: Node3D, set_last_tile = false):
	var ends: Array[Node] = []
	if last_tile.name.contains("End"):
		ends.append(last_tile)
		
	elif last_tile.get_child(0) != null:
		if last_tile.get_child(0).name == "Ends":
			ends = last_tile.get_child(0).get_children() # Ends container MUST be the first child
		else:
			printerr("Tile is not an End or an Ends container!")
	
	if ends.size() == 1:
		target_tile.global_transform = ends[0].global_transform
	else:
		var selected_end = ends.pick_random()
		target_tile.global_transform = selected_end.global_transform
		ends.erase(selected_end)
		end_nodes.append_array(ends)
	
	if set_last_tile:
		last_tile = target_tile
