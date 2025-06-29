extends Node3D

@export var sensitivity = 5
@onready var springArm = $SpringArm3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = get_tree().get_nodes_in_group("World")[0].global_position

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation = Vector3(clamp(rotation.x - event.relative.y / 1000 * sensitivity, -1, 0.25), rotation.y - event.relative.x / 1000 * sensitivity, 0)
	if event is InputEventMouseButton:
		if Input.is_action_pressed("scroll_up") || Input.is_action_pressed("scroll_down"):
			if Input.get_axis("scroll_down", "scroll_up") < 0.5:
				springArm.spring_length += 0.5
			else:
				springArm.spring_length -= 0.5
