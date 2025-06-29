extends Node3D

@onready var cam: Camera3D = $Camera3D
var camTargetCollider: CollisionShape3D
@export var camTarget: Node3D
@export var useCamTargetChild: bool
var camTargetParent: Node3D
@export var camSensitivity = 5
var camRotation: Vector3

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
		global_rotation.x = camRotation.x
		if not useCamTargetChild:
			camTarget.global_rotation.y = camRotation.y
		else:
			camTargetParent.global_rotation.y = camRotation.y
	# zooms camera based on scrollwheel input
	if event is InputEventMouseButton:
		if Input.is_action_pressed("scroll_up") || Input.is_action_pressed("scroll_down"):
			if Input.get_axis("scroll_down", "scroll_up") > 0.5:
				var tween = get_tree().create_tween()
				tween.tween_property(cam, "fov", 40, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
			else:
				var tween = get_tree().create_tween()
				tween.tween_property(cam, "fov", 86, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

# sets parent position and rotation to match target
func _process(delta: float) -> void:
	global_position = camTarget.global_position
	if not useCamTargetChild:
		global_position.y = camTarget.global_position.y + (camTarget.scale.y * 1.5)
	else:
		global_position.y = camTarget.global_position.y
	global_rotation.y = camTarget.global_rotation.y
