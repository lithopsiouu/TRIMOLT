extends State

@onready var npc: Npc = self.get_parent().get_parent()

## Npc following state.

func enter() -> void:
	npc.wandering = false

func update(_delta: float) -> void:
	
	# If npc has no destination
	if npc.destination_reached:
		state_machine.change_state("idle")
