extends State

## Sprinting movement state.

@onready var player: PlayerController = self.get_parent().get_parent()

func enter() -> void:
	player.crouching = false

func update(_delta: float) -> void:
	# If not moving:
	if abs(player.move_input.length()) == 0.0:
		
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
	
	elif player.sprinting == false:
		state_machine.change_state("walking")
	
	# If jumping:
	elif player.jumping:
		state_machine.change_state("jumping")
	
	# If crouching
	elif player.crouching:
		state_machine.change_state("crouchmoving")
