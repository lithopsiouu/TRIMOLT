extends Door

#@export var door_mesh: Mesh = BoxMesh.new()

## A door that rotates in a direction when interacted with. 

@export_category("Door Functions")
@export_group("Transform")
@export var start_position: float = 0.0
@export var max_rotation_deg: float = 90
var open_rotation: float
var close_rotation: float

func _ready() -> void:
	close_rotation = rotation_degrees.y
	open_rotation = max_rotation_deg
	if abs(start_position) > 0.0:
		rotation_degrees.y = start_position
	_init_is_open()
	_hide_editor_sprite()

func activate():
	door_rotate(open_rotation, open_move_time, open_transition_type, open_ease_type)

func deactivate():
	door_rotate(close_rotation, close_move_time, close_transition_type, close_ease_type)

## [b]Tweens[/b] the position of the [param door] to [param end_pos],[br]otherwise sets position if [param move_time] is [code]> 0[/code].
func door_rotate(end_rot: float, move_time, trans, ease) -> void:
	if move_time > 0.0:
		interactable.cooldown = move_time
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(self, "rotation_degrees", Vector3(0, end_rot, 0), move_time).set_trans(trans).set_ease(ease)
	else:
		rotation_degrees.y = end_rot
