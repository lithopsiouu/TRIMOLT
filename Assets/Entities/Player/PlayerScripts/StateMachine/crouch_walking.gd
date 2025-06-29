extends State

@onready var body: Player = get_parent().get_parent()
@onready var crouchCheck: ShapeCast3D = get_parent().get_parent().find_child("CrouchCheck")
@onready var slippingCheck: ShapeCast3D = get_parent().get_parent().find_child("SlippingCheck")

func enter() -> void:
	body.crouch_tween()

func update(delta:float) -> void:
	if not body.is_on_floor() and body.input_dir != Vector2.ZERO:
		body.uncrouch_tween()
		state_machine.change_state("airmoving")
		
	elif not body.is_on_floor():
		body.uncrouch_tween()
		state_machine.change_state("falling")
		
	elif body.input_dir != Vector2.ZERO and not Input.is_action_pressed("Crouch") and not crouchCheck.is_colliding():
		body.uncrouch_tween()
		state_machine.change_state("walking")
		
	elif body.input_dir == Vector2.ZERO and not Input.is_action_pressed("Crouch") and not crouchCheck.is_colliding():
		body.uncrouch_tween()
		state_machine.change_state("idle")
		
	elif body.input_dir == Vector2.ZERO:
		state_machine.change_state("crouching")
	
	if not slippingCheck.is_colliding() and body.is_on_floor():
		body.velocity += body.get_gravity() * delta * body.v_accel
	
	body.velocity.x = move_toward(body.velocity.x, body.direction.x * body.crouchSpeed, body.h_accel * delta)
	body.velocity.z = move_toward(body.velocity.z, body.direction.z * body.crouchSpeed, body.h_accel * delta)
	body.move_and_slide()
