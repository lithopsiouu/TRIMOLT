extends Node
const TILE_SPLIT = preload("res://Scenes/Map Generation Tiles/Test Tiles/tile_split.tscn")
const TILE_START = preload("res://Scenes/Map Generation Tiles/Test Tiles/tile_start.tscn")
const TILE_STRAIGHT = preload("res://Scenes/Map Generation Tiles/Test Tiles/tile_straight.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var start = TILE_START.instantiate()
	get_tree().root.add_child(start)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
