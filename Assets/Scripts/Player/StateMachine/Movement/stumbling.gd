extends State

## Movement state.

@onready var player: PlayerController = self.get_parent().get_parent()

func enter() -> void:
	player.crouching = false
	player.sprinting = false
	player.stumble()

func update(_delta: float) -> void:
	
	# If in air
	if player.ground_check.is_colliding() == false:
		state_machine.change_state("falling")
		
	# If stumbling is done:
	elif player.can_stumble == true:
		
		# If jumping:
		if player.jumping:
			state_machine.change_state("jumping")
		
		# If moving:
		if player.move_input.length() > 0.0:
			
			# and no ground:
			if player.ground_check.is_colliding() == false:
				state_machine.change_state("fallmoving")
			
			# and sprinting:
			elif player.sprinting:
				state_machine.change_state("sprinting")
			
			# and crouching:
			elif player.crouching:
				state_machine.change_state("crouchmoving")
			
			else:
				state_machine.change_state("walking")
		
		# If crouching
		elif player.crouching:
			state_machine.change_state("crouchidle")
		
		else:
			state_machine.change_state("idle")
