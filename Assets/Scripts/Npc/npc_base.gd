class_name NpcBase extends Node3D

## Base for npc movement. Allows for controlling

@onready var head_height: RayCast3D = $RayCast3D
@onready var head_detector: ShapeCast3D = $ShapeCast3D
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

var npc_head_height: float = 1.0
var npc_detection_direction: Vector3 = Vector3.FORWARD
var npc_detection_distance: int = 1.0
var move_speed: float = 0.3

var destination_reached: bool = true

var npc_detection_transform: Vector3

func _init() -> void:
	npc_detection_transform = npc_detection_direction.normalized() * npc_detection_distance
	

func _ready() -> void:
	head_height.target_position = Vector3(0, -npc_head_height, 0)
	head_detector.target_position = npc_detection_transform
	
	global_position.y = npc_head_height
	
	nav_agent.connect("target_reached", _on_destination_reached)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Mental_Map_Camera_Pan"):
		var randompos := Vector3.ZERO
		randompos.z = randf_range(-5.0, 5.0)
		randompos.x = randf_range(-5.0, 5.0)
		set_new_nav_target_pos(randompos)


func _physics_process(delta: float) -> void:
	if destination_reached == false:
		var destination = nav_agent.get_next_path_position()
		var local_destination = destination - global_position
		var direction = local_destination.normalized() 
		
		global_position += direction * move_speed

## Sets the navigation agent's target position.
func set_new_nav_target_pos(pos: Vector3) -> void:
	destination_reached = false
	nav_agent.target_position = pos

func _on_destination_reached() -> void:
	destination_reached = true
	print("destination reached")
