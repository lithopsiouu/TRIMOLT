class_name Door extends Interaction

@onready var door: Area3D = $Interactable
@export_category("Door Visualization")
@onready var door_editor_sprite: Sprite3D = $Sprite3D

enum TRANSITION_TYPES { 
	LINEAR = 0,
	SINE = 1,
	QUINT = 2,
	QUART = 3,
	QUAD = 4,
	EXPO = 5,
	ELASTIC = 6,
	CUBIC = 7,
	CIRC = 8,
	BOUNCE = 9,
	BACK = 10
}
@export_group("Transitions")
@export var open_transition_type = TRANSITION_TYPES.CIRC
@export var close_transition_type = TRANSITION_TYPES.CIRC

enum EASE_TYPES {
	EASE_IN = 0,
	EASE_OUT = 1,
	EASE_IN_OUT = 2,
	EASE_OUT_IN = 3
}
@export_group("Easings")
@export var open_ease_type = EASE_TYPES.EASE_OUT
@export var close_ease_type = EASE_TYPES.EASE_OUT

@export_category("Door Opening")
@export var is_open: bool = false
@export_group("Move Time")
@export var open_move_time: float = 0.0
@export var close_move_time: float = 0.0

func _ready() -> void:
	_init_is_open()
	_hide_editor_sprite()

## Sets the [param interactable] toggle state to [param is_open]
func _init_is_open() -> void:
	if is_open:
		interactable.toggle_state = is_open
		activate()

func _hide_editor_sprite() -> void:
	if door_editor_sprite != null:
		door_editor_sprite.visible = false
