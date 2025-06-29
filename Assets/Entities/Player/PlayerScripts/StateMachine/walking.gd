extends State

@onready var body: Player = get_parent().get_parent()

func update(delta:float) -> void:
	if not body.is_on_floor() and body.input_dir != Vector2.ZERO:
		state_machine.change_state("airmoving")
		
	elif not body.is_on_floor():
		state_machine.change_state("falling")
		
	elif body.input_dir != Vector2.ZERO and Input.is_action_pressed("Sprint"):
		state_machine.change_state("running")
		
	elif body.input_dir == Vector2.ZERO:
		state_machine.change_state("idle")
		
	elif Input.is_action_pressed("Jump"):
		if body.topSurfaceRay.is_colliding() and not body.collider.disabled:
			state_machine.change_state("edgeclimbing")
		else:
			state_machine.change_state("jumping")
		
	elif Input.is_action_pressed("Crouch"):
		state_machine.change_state("crouchwalking")
		
	body.velocity.x = move_toward(body.velocity.x, body.direction.x * body.walkSpeed, body.h_accel * delta)
	body.velocity.z = move_toward(body.velocity.z, body.direction.z * body.walkSpeed, body.h_accel * delta)
	
	#body.velocity.x = body.direction.x * body.walkSpeed #.rotated(Vector3.UP, body.global_rotation.y)
	#body.velocity.z = body.direction.z * body.walkSpeed #.rotated(Vector3.UP, body.global_rotation.y)
	body.move_and_slide()
