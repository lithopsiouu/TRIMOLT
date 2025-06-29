extends State

@onready var body: Player = get_parent().get_parent()

func update(delta:float) -> void:
	body.velocity.y = body.jumpVelocity
	
	if body.is_on_floor() and body.velocity.y == 0:
		state_machine.change_state("idle")
		
	elif body.input_dir != Vector2.ZERO:
		state_machine.change_state("airmoving")
		
	elif not body.is_on_floor():
		state_machine.change_state("falling")
	
	body.move_and_slide()
