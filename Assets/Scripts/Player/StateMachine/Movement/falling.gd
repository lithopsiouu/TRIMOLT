extends State

## Falling movement state.

@onready var player: PlayerController = self.get_parent().get_parent()

func enter() -> void:
	player.jumping = false
	player.can_sprint = true
	
	if state_machine.last_state != state_machine.states.get("fallmoving"):
		player.init_fall_pos = player.global_position

func update(_delta: float) -> void:
	
	# If grounded
	if player.ground_check.is_colliding():
		
		# If falling faster than stumble velocity
		if player.linear_velocity.y < player.MIN_STUMBLE_VELOCITY:
			# And stumbling is possible
			if player.can_stumble: state_machine.change_state("stumbling")
		
		# If falling higher than minimum land height
		elif player.fall_height > player.MIN_LAND_HEIGHT:
			state_machine.change_state("landing")
		
		# If moving
		elif player.move_input.length() > 0.0:
			
			# If sprinting
			if player.sprinting:
				state_machine.change_state("sprinting")
			
			# If crouching:
			elif player.crouching:
				state_machine.change_state("crouchmoving")
			
			else:
				state_machine.change_state("walking")
			
		else:
			
			# if crouching:
			if player.crouching:
				state_machine.change_state("crouchidle")
				
			else:
				state_machine.change_state("idle")
	
	else:
		if player.move_input.length() > 0.0:
			state_machine.change_state("fallmoving")
