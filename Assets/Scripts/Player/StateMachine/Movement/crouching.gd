extends State

## Movement state.

@onready var player: PlayerController = self.get_parent().get_parent()

func enter() -> void:
	player.sprinting = false

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
