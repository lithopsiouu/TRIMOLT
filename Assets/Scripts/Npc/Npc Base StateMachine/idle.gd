extends State

@onready var npc: Npc = self.get_parent().get_parent()

## Npc idle state.

func enter() -> void:
	npc.wandering = false

func update(_delta: float) -> void:
	
	# If npc is wandering
	if npc.wandering:
		state_machine.change_state("wandering")
	
	# If npc has a destination
	if npc.destination_reached == false:
		state_machine.change_state("following")
