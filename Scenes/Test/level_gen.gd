extends Node

@onready var level_holder: Node3D = $"../LevelHolder"

var last_tile: Node = null
var max_level_length: int = 8
var max_branch_length: int = 3
var end_branches: Array

const TILE_START = preload("res://Scenes/Map Generation Tiles/Test Tiles/tile_start.tscn")
const TILE_END = preload("res://Scenes/Map Generation Tiles/Test Tiles/tile_end.tscn")

var test_tiles_path: String = "res://Scenes/Map Generation Tiles/Test Tiles/tile_%s.tscn"
var all_test_tiles: Array = [
	"straight",
	"split",
	"straight_room"
]

func _get_test_node(array_index) -> PackedScene:
	var test_node:PackedScene = null
	if array_index < all_test_tiles.size():
		test_node = load(test_tiles_path % all_test_tiles[array_index])
	return test_node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var start = TILE_START.instantiate()
	var end = TILE_END.instantiate()
	
	if level_holder.ready: level_holder.add_child(start)
	last_tile = level_holder.get_child(0)
	
	for i in range(max_level_length):
		#_add_test_tile(1)
		_add_test_tile(randi_range(0, (all_test_tiles.size() -1)))
	level_holder.add_child(end)
	_connect_tile(end)
	
	for branch in end_branches.size():
		var branch_end = TILE_END.instantiate()
		level_holder.add_child(branch_end)
		_connect_tile_at_end(branch_end, end_branches[branch])
	print(end_branches.size())

func _add_test_tile(array_index: int):#add array field in non-test func
	var node: Node3D = _get_test_node(array_index).instantiate()
	level_holder.add_child(node)
	_connect_tile(node)
	last_tile = node

func _connect_tile(target_node: Node3D):
	var lastTile: Node3D = last_tile.find_child("End")
	if lastTile == null:
		var randTile = randi_range(1,2)
		lastTile = last_tile.find_child("End" + str(randTile))
		if (randTile/2) == 1:
			end_branches.append(last_tile.find_child("End1"))
		else:
			end_branches.append(last_tile.find_child("End2"))
	target_node.global_transform = lastTile.global_transform

func _connect_tile_at_end(target_node: Node3D, end_node: Node3D):
	target_node.global_transform = end_node.global_transform
