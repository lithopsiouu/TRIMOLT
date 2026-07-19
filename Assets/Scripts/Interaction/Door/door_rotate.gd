extends Door

#@export var door_mesh: Mesh = BoxMesh.new()

## A door that rotates in a direction when interacted with. 

enum FORWARD_DIRECTION {X,Y,Z}

@onready var visualization: MeshInstance3D = $Visualization
@onready var orientation: Node3D = $Orientation
@export_category("Door Functions")
@export_group("Transform")
@export var start_position: float = 0.0 ## Angle in degrees the door starts with. Used for making a door spawn ajar
@export var max_rotation_deg: float = 90 ## Angle in degrees that the door will open.
@export var forward_direction: FORWARD_DIRECTION ## Not yet supported.
var rotation_adjustment: float
var door_direction: Vector3
var open_rotation: float
var close_rotation: float

func _ready() -> void:
	max_rotation_deg = abs(max_rotation_deg)
	close_rotation = rotation_degrees.y
	open_rotation = max_rotation_deg
	orientation.visible = false
	if abs(start_position) > 0.0:
		rotation_degrees.y = start_position
	_init_is_open()
	_hide_editor_sprite()

func activate(_player: PlayerController = null):
	if get_player_relative(_player) > 0:
		door_rotate(close_rotation - open_rotation, open_move_time, open_transition_type, open_ease_type)
	else:
		door_rotate(close_rotation + open_rotation, open_move_time, open_transition_type, open_ease_type)

func deactivate(_player: PlayerController = null):
	door_rotate(close_rotation, close_move_time, close_transition_type, close_ease_type)

## [b]Tweens[/b] the position of the [param door] to [param end_pos],[br]otherwise sets position if [param move_time] is [code]> 0[/code].
func door_rotate(end_rot: float, move_time, trans, ease) -> void:
	if move_time > 0.0:
		interactable.cooldown = move_time
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(self, "rotation_degrees", Vector3(0, end_rot, 0), move_time).set_trans(trans).set_ease(ease)
	else:
		rotation_degrees.y = end_rot

func get_player_relative(player: PlayerController) -> float:
	match forward_direction:
		FORWARD_DIRECTION.X:
			door_direction = orientation.global_transform.basis.x
		FORWARD_DIRECTION.Y:
			door_direction = orientation.global_transform.basis.y
		FORWARD_DIRECTION.Z:
			door_direction = orientation.global_transform.basis.z
	
	var player_position: Vector3 = player.global_position
	var dir_to_player: Vector3 = global_position.direction_to(player_position)
	var dot: float = dir_to_player.dot(door_direction)
	
	return dot
