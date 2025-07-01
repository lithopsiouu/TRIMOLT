class_name Player extends CharacterBody3D

signal edge_climb_done

var input_dir: Vector2
var direction: Vector3

# speeds tend to be pretty close to m/s
var jumpVelocity: float = 7
var crouchSpeed: float = 1.5
var airSpeed: float = 2
var walkSpeed: float = 2.2
var runSpeed: float = 4.1
var h_accel := 15.0
var v_accel := 1.0

var climbAngleTolerance: float = -0.7
var verticalClimbDistReduction: float = 1.7

@onready var climbDetect: ShapeCast3D = $ClimbCheck
@onready var topSurfaceRay: RayCast3D = $TopSurface
@onready var collider: CollisionShape3D = $Collider

func _process(delta: float) -> void:
	input_dir = Input.get_vector("Left", "Right", "Forward", "Backward")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

func crouch_tween():
	var tweenCrouch = get_tree().create_tween()
	tweenCrouch.tween_property(self, "scale:y", 0.48, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func uncrouch_tween():
	var tweenUncrouch = get_tree().create_tween()
	tweenUncrouch.tween_property(self, "scale:y", 1, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func _climb_edge():
	var collisionNormal = climbDetect.get_collision_normal(0)
	var forwardBodyVectorRotated = Vector3.FORWARD.rotated(Vector3.UP, global_rotation.y)
	var normalDifference = collisionNormal.dot(forwardBodyVectorRotated)
	
	# check if player angle isnt too different from normal
	if normalDifference < climbAngleTolerance and _get_top_surface_collision_point() != Vector3.ZERO:
		var verticalDifference: float = clampf(((_get_top_surface_collision_point().y - global_position.y) / verticalClimbDistReduction), 0.5, 3)
		print("Successful mantle")
		
		collider.disabled = true
		var tweenX = get_tree().create_tween()
		var tweenZ = get_tree().create_tween()
		var tweenY = get_tree().create_tween()
		tweenX.tween_property(self, "global_position:x", _get_top_surface_collision_point().x, verticalDifference).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
		tweenZ.tween_property(self, "global_position:z", _get_top_surface_collision_point().z, verticalDifference).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
		tweenY.tween_property(self, "global_position:y", _get_top_surface_collision_point().y, verticalDifference).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
		await tweenY.finished
		collider.disabled = false
		velocity.y = -1
		edge_climb_done.emit()
	else:
		print("Can't mantle")
		edge_climb_done.emit()

func _get_top_surface_collision_point() -> Vector3:
	var returnVector = Vector3.ZERO
	
	if topSurfaceRay.get_collision_normal() != returnVector and topSurfaceRay.is_colliding():
		returnVector = topSurfaceRay.get_collision_point()
	return returnVector
