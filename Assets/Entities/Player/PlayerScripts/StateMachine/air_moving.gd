extends State

@onready var body: Player = get_parent().get_parent()

func update(delta:float) -> void:
	#body.velocity = Vector3(clamp(body.velocity.x + (body.direction.x * body.airSpeed), -body.velocity.x, body.velocity.x), body.velocity.y, clamp(body.velocity.z + (body.direction.z * body.airSpeed), -body.velocity.x, body.velocity.z))
	body.velocity.y += body.get_gravity().y * delta * body.v_accel
	body.velocity.x = move_toward(body.velocity.x, clamp(body.velocity.x + (body.direction.x * body.airSpeed), -body.velocity.x, body.velocity.x), (body.h_accel / 1.3) * delta)
	body.velocity.z = move_toward(body.velocity.z, clamp(body.velocity.z + (body.direction.z * body.airSpeed), -body.velocity.x, body.velocity.z), (body.h_accel / 1.3) * delta)
	#body.velocity.x *= abs(body.direction.x)
	#body.velocity.z *= abs(body.direction.y)
	body.move_and_slide()
	
	if body.input_dir != Vector2.ZERO and body.is_on_floor():
		state_machine.change_state("walking")
		
	elif body.input_dir != Vector2.ZERO and body.is_on_floor() and Input.is_action_pressed("Crouch"):
		state_machine.change_state("crouchwalking")
		
	elif body.is_on_floor():
		state_machine.change_state("idle")
	
	elif Input.is_action_just_pressed("Jump"):
		if body.topSurfaceRay.is_colliding() and not body.collider.disabled:
			state_machine.change_state("edgeclimbing")
		
	elif body.input_dir == Vector2.ZERO and not body.is_on_floor():
		state_machine.change_state("falling")
