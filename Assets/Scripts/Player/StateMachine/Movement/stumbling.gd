extends State

## Movement state.

@onready var player: PlayerController = self.get_parent().get_parent()
var _vel_diff: float = 0.0
var _stumble_time: float = 0.0
const STUMBLE_TIME_MOD: float = 0.8
const STUMBLE_STRENGTH_MOD: float = 0.3

func enter() -> void:
	player.crouching = false
	player.sprinting = false
	
	if player.can_stumble:
		_vel_diff = -player.linear_velocity.y + player.MIN_STUMBLE_VELOCITY
		_stumble_time = _vel_diff * STUMBLE_TIME_MOD
		
		player.stumble_time = _stumble_time
		player.stumble_strength = _stumble_time * STUMBLE_STRENGTH_MOD
		player.stumble()
	else:
		print("Couldn't stumble.")

func update(_delta: float) -> void:
	if player.stumbling == false:
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
