class_name NpcDirector extends Node

## Directs Npcs to specific locations.

@onready var wander_timer: Timer = $WanderTimer

@export_category("Idle Settings")
@export_subgroup("Wandering")
@export var use_wander_timer: bool = true
@export var wander_time: float = 8

var npcs: Array[Npc] = []

func _ready() -> void:
	wander_timer.wait_time = wander_time
	wander_timer.autostart = use_wander_timer
	wander_timer.start()
	get_all_npcs()

func get_all_npcs() -> void:
	for child in get_children():
		if child is Npc: npcs.append(child)

## Returns a random position within the radius of a point
func get_pos_around_point(point: Vector3, radius: float) -> Vector3:
	
	var rand_pos: Vector3 = Vector3.ZERO ## A random position in a radius
	
	# Get a random position within a radius around the point
	var rand_float_a: float = randi_range(-1, 1)
	var rand_float_b: float = randi_range(-1, 1)
	var pos_in_radius: Vector3 = Vector3(rand_float_a, 0, rand_float_b).normalized()
	pos_in_radius *= radius
	
	rand_pos = point + pos_in_radius
	
	return rand_pos

func _on_wander_timer_timeout() -> void:
	
	var rand_num: float = 5
	var rand_range_x: float = randf_range(-rand_num, rand_num)
	var rand_range_z: float = randf_range(-rand_num, rand_num)
	var rand_vec3: Vector3 = Vector3(rand_range_x, 0, rand_range_z)
	
	for npc in npcs:
		if npc.has_method("set_wander_nav_target_pos"):
			npc.set_wander_nav_target_pos(get_pos_around_point(rand_vec3, 0.8))
