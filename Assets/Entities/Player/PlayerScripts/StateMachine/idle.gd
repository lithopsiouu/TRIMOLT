extends State

@onready var body: Player = get_parent().get_parent()
@onready var slippingCheck: ShapeCast3D = get_parent().get_parent().find_child("SlippingCheck")

func update(delta:float) -> void:
	
	if Input.is_action_pressed("Jump"):
		if body.topSurfaceRay.is_colliding() and not body.collider.disabled:
			state_machine.change_state("edgeclimbing")
		else:
			state_machine.change_state("jumping")
	elif body.is_on_floor() and Input.is_action_just_pressed("Crouch"):
		state_machine.change_state("crouching")
		
	elif not body.is_on_floor():
		state_machine.change_state("falling")
		
	elif body.is_on_floor() and body.input_dir != Vector2.ZERO and Input.is_action_pressed("Sprint"):
		state_machine.change_state("running")
		
	elif body.is_on_floor() and body.input_dir != Vector2.ZERO:
		state_machine.change_state("walking")
		
	
	if not slippingCheck.is_colliding() and body.is_on_floor():
		body.velocity += body.get_gravity() * delta * body.v_accel
	
	body.velocity.x = move_toward(body.velocity.x, 0, body.h_accel * delta)
	body.velocity.z = move_toward(body.velocity.z, 0, body.h_accel * delta)
	body.move_and_slide()
