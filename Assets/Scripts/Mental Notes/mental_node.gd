class_name MentalNode
extends Node2D

## A [MentalNode] that is used by [MentalNote], [MentalQuestion], and [MentalConnection] classes.

const MENTAL_NODE_TEST = preload("res://Assets/UI/Mental_Map/mental_node_test.tscn")

signal mouse_over
signal mouse_off
signal connected

var tags: Array = []
var content: String = ""
var _ID: int = -1
var ID_pairs: Array[int] = [] ## ID of other [MentalNode] that will create a [MentalConnection].
var color: Color = Color.WHITE
var node: Area2D

var following_mouse: bool = false
var max_distance_from_mouse: float = 300
var init_pos: Vector2
var move_speed: float = 0
var normal_move_speed: float = 9
var fast_move_speed: float = 20

func _init() -> void:
	init_pos = global_position
	
	node = MENTAL_NODE_TEST.instantiate()
	add_child(node)
	node.mouse_entered.connect(_on_mouse_enter)
	node.mouse_exited.connect(_on_mouse_exit)
	node.area_entered.connect(on_area_entered)
	
	node.get_child(0).self_modulate = color

func _process(delta: float) -> void:
	if following_mouse:
		var mouse_pos = get_global_mouse_position()
		
		keep_up_speed(mouse_pos)
		
		global_position = global_position.lerp(mouse_pos, delta * move_speed)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_released("Mental_Map_Node_Grab"):
		set_following_mouse(false)

func keep_up_speed(mouse_pos: Vector2) -> void:
	if global_position.distance_to(mouse_pos) > max_distance_from_mouse:
		move_speed = fast_move_speed
	else:
		move_speed = normal_move_speed

func _on_mouse_enter() -> void:
	mouse_over.emit(self)

func _on_mouse_exit() -> void:
	mouse_off.emit(self)

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
	
	get_child(0).get_child(-1).text = content


## Returns [param _ID].
func get_ID() -> int:
	return _ID

## Sets [param _ID].
func set_ID(new_ID: int) -> void:
	_ID = new_ID


## Sets [param following_mouse] to [param state].
func set_following_mouse(state: bool) -> void:
	following_mouse = state


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


func get_color() -> Color:
	return color

func set_color(new_color: Color) -> void:
	color = new_color
	node.get_child(0).self_modulate = new_color


func on_area_entered(area: Area2D) -> void:
	if area.get_parent().has_method("get_ID"):
		if ID_pairs.size() <= 0:
			return
		if ID_pairs[0] == area.get_parent().get_ID():
			print("id is same")
			connected.emit(self, area.get_parent())
