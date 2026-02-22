extends State

@onready var body: Player = get_parent().get_parent()

func update(delta:float) -> void:
	if body.runAmt > 0:
		if not body.is_on_floor() and body.input_dir != Vector2.ZERO:
			state_machine.change_state("airmoving")
			
		elif not body.is_on_floor():
			state_machine.change_state("falling")
			
		elif body.input_dir != Vector2.ZERO and not Input.is_action_pressed("Sprint"):
			state_machine.change_state("walking")
			
		elif body.input_dir == Vector2.ZERO:
			state_machine.change_state("idle")
			
		elif Input.is_action_pressed("Jump"):
			if body.topSurfaceRay.is_colliding():
				state_machine.change_state("edgeclimbing")
			else:
				state_machine.change_state("jumping")
			
		elif Input.is_action_pressed("Crouch"):
			state_machine.change_state("crouchwalking")
	else:
		state_machine.change_state("walking")
	
	body.velocity.x = move_toward(body.velocity.x, body.direction.x * body.runSpeed, body.h_accel * 2 * delta)
	body.velocity.z = move_toward(body.velocity.z, body.direction.z * body.runSpeed, body.h_accel* 2 * delta)
	body.move_and_slide()

func exit():
	if body.runAmt > 0:
		$"../../RunWait".start()
	else:
		$"../../RunExhaustCooldown".start()
