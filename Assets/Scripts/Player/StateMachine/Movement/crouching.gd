extends State

## Movement state.

@onready var player: PlayerController = self.get_parent().get_parent()

func enter() -> void:
	player.sprinting = false
	player.jumping = false

func update(_delta: float) -> void:
	
	# If moving:
	if player.move_input.length() > 0.0:
		state_machine.change_state("crouchmoving")
	
	else:
		state_machine.change_state("crouchidle")

# stumbling
# jumping
# crouchmoving
# crouching
# idle
# walking
# sprinting
# fallmoving
# falling
# landing
