extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5


func _physics_process(delta: float) -> void:

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	$AnimationTree.set("parameters/conditions/moving", direction != Vector3.ZERO)
	$AnimationTree.set("parameters/conditions/idle", direction == Vector3.ZERO)
	
	var currentRotation = transform.basis.get_rotation_quaternion()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.x = (currentRotation.normalized().x * $AnimationTree.get_root_motion_position().x) / delta
		velocity.y += get_gravity().y * delta
		velocity.z = (currentRotation.normalized().z * $AnimationTree.get_root_motion_position().z) / delta
	else:
		velocity = (currentRotation.normalized() * $AnimationTree.get_root_motion_position()) / delta
	
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
