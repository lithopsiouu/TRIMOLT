extends Camera2D

@export var zoom_speed: float = 6
var zoom_target: Vector2
var max_zoom: float = 1.5
var min_zoom: float = 0.5

@export var move_speed: float = 800
var move_input: Vector2 = Vector2.ZERO ## Direction of movement input

var mouse_down_pos: Vector2 = Vector2.ZERO
var drag_start_camera_pos: Vector2 = Vector2.ZERO
var is_dragging: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	zoom_target = zoom


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move_input = Input.get_vector("Mental_Map_Move_Left", "Mental_Map_Move_Right", "Mental_Map_Move_Up", "Mental_Map_Move_Down", 0.1)
	
	_zoom(delta)
	_simple_pan(delta)
	_click_and_drag()

func _zoom(delta: float) -> void:
	if Input.is_action_just_pressed("Mental_Map_Zoom_In"):
		zoom_target *= 1.1
	
	if Input.is_action_just_pressed("Mental_Map_Zoom_Out"):
		zoom_target *= 0.9
	
	zoom = zoom.slerp(zoom_target, delta * zoom_speed)

func _simple_pan(delta: float) -> void:
	var move_amount: Vector2 = Vector2.ZERO
	if move_input.length() > 0:
		move_amount.x += move_input.x
		move_amount.y += move_input.y
	
	move_amount = move_amount.normalized()
	position += move_amount * delta * move_speed * (1/zoom.x)

func _click_and_drag() -> void:
	if is_dragging == false and Input.is_action_just_pressed("Mental_Map_Camera_Pan"):
		mouse_down_pos = get_viewport().get_mouse_position()
		drag_start_camera_pos = position
		is_dragging = true
	
	if is_dragging and Input.is_action_just_released("Mental_Map_Camera_Pan"):
		is_dragging = false
	
	if is_dragging:
		var move_vec = get_viewport().get_mouse_position() - mouse_down_pos
		position = drag_start_camera_pos - move_vec * (1/zoom.x)
