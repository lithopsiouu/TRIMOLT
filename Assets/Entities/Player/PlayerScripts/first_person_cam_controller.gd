extends Node3D

@onready var cam: Camera3D = $Camera3D
var camTargetCollider: CollisionShape3D
@export var camTarget: Node3D
@export var useCamTargetChild: bool
var camTargetParent: Node3D

@export var camSensitivity = 5
@export var joyCamSensitivity = 11

var camRotation: Vector3
var joyCamRotation: Vector3

var useJoy: bool = false

# locks mouse and sets camTargetCollider reference
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if useCamTargetChild:
		camTargetCollider = camTarget.get_parent().find_child("Collider")
		camTargetParent = camTarget.get_parent()
	else:
		camTargetCollider = camTarget.find_child("Collider")

func _input(event: InputEvent) -> void:
	# gets rotation from mouse movement as a Vector3 then rotates parent.x by camRotation.x and rotates camTarget.y by camRotation.y
	if event is InputEventMouseMotion:
		camRotation = Vector3(clamp(rotation.x - event.relative.y / 1000 * camSensitivity, -1.4, 1.4), rotation.y - event.relative.x / 1000 * camSensitivity, 0)
		_set_cam_rotation(camRotation)

# sets parent position and rotation to match target
func _process(delta: float) -> void:
	if useJoy:
		joyCamRotation += Vector3(Input.get_axis("cam_look_down", "cam_look_up") / 1000 * joyCamSensitivity, Input.get_axis("cam_look_right", "cam_look_left") / 1000 * joyCamSensitivity, 0)
		joyCamRotation.x = clamp(joyCamRotation.x, -1.4, 1.4)
		if joyCamRotation != Vector3.ZERO:
			_set_cam_rotation(joyCamRotation)
	
	global_position.x = camTarget.global_position.x
	global_position.z = camTarget.global_position.z
	if not useCamTargetChild:
		global_position.y = camTarget.global_position.y
	else:
		global_position.y = camTarget.global_position.y
	global_rotation.y = camTarget.global_rotation.y

func _set_cam_rotation(rotToUse: Vector3) -> void:
	global_rotation.x = rotToUse.x
	if not useCamTargetChild:
		camTarget.global_rotation.y = rotToUse.y
	else:
		camTargetParent.global_rotation.y = rotToUse.y
