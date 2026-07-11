extends Door

#@export var door_mesh: Mesh = BoxMesh.new()

@export_category("Door Functions")
@export_group("Transform")
@export var slide_direction: Vector3 = Vector3.UP
@export var slide_distance: float = 2
var open_position: Vector3
var close_position: Vector3

func _ready() -> void:
	slide_direction = slide_direction.normalized()
	close_position = door.position
	open_position = slide_direction * slide_distance
	_init_is_open()
	_hide_editor_sprite()

func activate():
	door_slide(open_position, open_move_time, open_transition_type, open_ease_type)

func deactivate():
	door_slide(close_position, close_move_time, close_transition_type, close_ease_type)

## [b]Tweens[/b] the position of the [param door] to [param end_pos],[br]otherwise sets position if [param move_time] is [code]> 0[/code].
func door_slide(end_pos: Vector3, move_time, trans, ease) -> void:
	if move_time > 0.0:
		interactable.cooldown = move_time
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(door, "position", end_pos, move_time).set_trans(trans).set_ease(ease)
	else:
		door.position = end_pos
