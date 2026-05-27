extends State

## Walking movement state

@onready var player: PlayerController = self.get_parent().get_parent()

func update(_delta: float) -> void:
	
	# if jumping:
	if player.jumping:
		state_machine.change_state("jumping")
	
	# If not moving:
	if player.move_input.length() == 0.0:
		
		# and no ground:
		if player.ground_check.is_colliding() == false:
			state_machine.change_state("falling")
		
		# and crouching:
		elif player.crouching:
			state_machine.change_state("crouching")
		
		else:
			state_machine.change_state("idle")
		
	# If in air
	elif player.ground_check.is_colliding() == false:
		state_machine.change_state("fallmoving")
	# If crouching
	elif player.crouching:
		state_machine.change_state("crouchmoving")

# jumping
# crouchmoving
# crouching
# idle
# walking
# sprinting
# fallmoving
# falling
# landing
