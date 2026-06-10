extends State

## Jumping movement state.

@onready var player: PlayerController = self.get_parent().get_parent()

func enter() -> void:
	player.can_sprint = true

func update(_delta: float) -> void:
	
	# If falling:
	if player.linear_velocity.y < 0.0:
		
		# If on ground:
		if player.ground_check.is_colliding():
			
			# If falling faster than min stumble velocity
			if player.linear_velocity.y < player.MIN_STUMBLE_VELOCITY:
				state_machine.change_state("stumbling")
			
			# If falling further than min land height
			elif player.fall_height > player.MIN_LAND_HEIGHT:
				state_machine.change_state("landing")
			else:
				state_machine.change_state("idle")
		
		# If moving:
		elif player.move_input.length() > 0.0:
			state_machine.change_state("fallmoving")
			
		else:
			state_machine.change_state("falling")
