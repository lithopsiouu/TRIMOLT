extends State

## Movement state.

@onready var player: PlayerController = self.get_parent().get_parent()

@export var stumble_altitude: float = 6.0

func enter() -> void:
	player.can_sprint = true

func update(_delta: float) -> void:
	# If falling from a great height:
	if player.fall_height > stumble_altitude:
		state_machine.change_state("stumbling")
	
	# If jumping
	elif player.jumping:
		state_machine.change_state("jumping")
	
	# If moving:
	if abs(player.move_input.length()) > 0.1:
		
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
		
	# If in air:
	elif player.ground_check.is_colliding() == false:
		state_machine.change_state("falling")
	
	# If crouching:
	elif player.crouching:
		state_machine.change_state("crouchidle")
	
	# If nothing:
	else:
		state_machine.change_state("idle")

func exit() -> void:
	player.fall_height = 0
