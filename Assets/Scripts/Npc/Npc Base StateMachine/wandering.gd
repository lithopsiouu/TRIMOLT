extends State

@onready var npc: Npc = self.get_parent().get_parent()

## Npc wandering state.

func update(_delta: float) -> void:
	
	if npc.wandering == false:
		
		# If npc has a destination
		if npc.destination_reached == false:
			state_machine.change_state("following")
		
		else:
			state_machine.change_state("idle")
