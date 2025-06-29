extends State

@onready var body: Player = get_parent().get_parent()

func update(delta:float) -> void:
	if body.is_on_floor():
		state_machine.change_state("idle")
		
	if body.is_on_floor() and Input.is_action_pressed("Crouch"):
		state_machine.change_state("crouching")
		
	elif Input.is_action_just_pressed("Jump"):
		if body.topSurfaceRay.is_colliding() and not body.collider.disabled:
			state_machine.change_state("edgeclimbing")
		
	elif body.input_dir != Vector2.ZERO:
		state_machine.change_state("airmoving")
	
	body.velocity += body.get_gravity() * delta * body.v_accel
	body.move_and_slide()
