class_name MentalNode
extends Node2D

## A [MentalNode] that is used by [MentalNote] and [MentalQuestion] classes.

const MENTAL_NODE_TEST = preload("res://Assets/UI/Mental_Map/mental_node_test.tscn")
var node

var tags: Array = []
var content: String = ""
var _ID: int = -1
var ID_pairs: Array[int] = [] ## ID of other [MentalNode] that will create a [MentalConnection].

var mouse_hovering: bool = false
var following_mouse: bool = false
var init_pos: Vector2
var move_speed: float = 9

func _init() -> void:
	init_pos = global_position
	
	node = MENTAL_NODE_TEST.instantiate()
	add_child(node)
	node.get_child(1).mouse_entered.connect(_on_mouse_enter)
	node.get_child(1).mouse_exited.connect(_on_mouse_exit)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Mental_Map_Node_Grab") and mouse_hovering:
		following_mouse = true
	
	if Input.is_action_just_released("Mental_Map_Node_Grab"):
		following_mouse = false

func _process(delta: float) -> void:
	if following_mouse:
		var mouse_pos = get_global_mouse_position()
		global_position = global_position.lerp(mouse_pos, delta * move_speed)

func _on_mouse_enter() -> void:
	mouse_hovering = true

func _on_mouse_exit() -> void:
	mouse_hovering = false

## Returns an [Array] of [param tags].
func get_tags() -> Array:
	return tags

## Sets [param tags].
func set_tags(new_tags: Array) -> void:
	tags = new_tags

## Appends [new_tags] to [tags].
func append_tags(new_tags: Array) -> void:
	tags.append_array(new_tags)


## Returns [param content].
func get_content() -> String:
	return content

## Sets [param content].
func set_content(new_content: String) -> void:
	content = new_content
	
	get_child(0).get_child(0).text = content


## Returns [param _ID].
func get_ID() -> int:
	return _ID

## Sets [param _ID].
func set_ID(new_ID: int) -> void:
	_ID = new_ID


## Returns [param ID_pair].
func get_ID_pair() -> Array:
	return ID_pairs

## Sets [param ID_pair].
func set_ID_pair(new_ID_pairs: Array) -> void:
	ID_pairs = new_ID_pairs

## Append an [int] to [param ID_pairs].
func append_ID_pair(new_ID_pair: int) -> void:
	ID_pairs.append(new_ID_pair)

## Append Array of pairs to [param ID_pairs].
func append_ID_pairs(new_ID_pairs: Array) -> void:
	ID_pairs.append_array(new_ID_pairs)
