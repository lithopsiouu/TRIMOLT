extends State

## Crouch idle movement state.

@onready var player: PlayerController = self.get_parent().get_parent()

func enter() -> void:
	player.can_stumble = true
	player.jumping = false

func update(_delta: float) -> void:
	
	# If stumbling:
	if player.stumbling:
		state_machine.change_state("stumbling")
	
	# If jumping:
	elif player.jumping:
		state_machine.change_state("jumping")
	
	# If moving:
	elif player.move_input.length() > 0.0:
		
		# and no ground:
		if player.ground_check.is_colliding() == false:
			state_machine.change_state("fallmoving")
		
		# and sprinting:
		elif player.sprinting:
			state_machine.change_state("sprinting")
		
		# If jumping:
		elif player.jumping:
			state_machine.change_state("jumping")
		
		else:
			state_machine.change_state("crouchmoving")
	
	# If in air
	elif player.ground_check.is_colliding() == false:
		state_machine.change_state("falling")
