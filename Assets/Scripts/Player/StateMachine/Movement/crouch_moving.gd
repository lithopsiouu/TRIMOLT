extends State

## Crouch moving movement state.

@onready var player: PlayerController = self.get_parent().get_parent()

func enter() -> void:
	player.sprinting = false
	player.jumping = false

func update(_delta: float) -> void:
	
	# If stumbling:
	if player.stumbling:
		state_machine.change_state("stumbling")
	
	# if jumping:
	elif player.jumping:
		state_machine.change_state("jumping")
	
	# If sprinting:
	elif player.sprinting:
		state_machine.change_state("sprinting")
	
	elif !player.crouching:
		state_machine.change_state("walking")
	
	# If not moving:
	elif player.move_input.length() == 0.0:
		
		# and no ground:
		if player.ground_check.is_colliding() == false:
			state_machine.change_state("falling")
		
		# and crouching:
		elif player.crouching:
			state_machine.change_state("crouchidle")
		
		else:
			state_machine.change_state("idle")
		
	# If in air
	elif player.ground_check.is_colliding() == false:
		state_machine.change_state("fallmoving")
