extends State

# to do:
# DONE: bring player to a point that is a certain distance from the edge using the front raycast and top raycast
# DONE: make transition from climbing to moving smoother so there is no snapping
# u simply forgot to reset the climbDone var doofus

@onready var body: Player = get_parent().get_parent()
var climbDone := false

func enter() -> void:
	climbDone = false
	body._climb_edge()

func update(delta: float) -> void:
	if climbDone:
		if body.input_dir != Vector2.ZERO: # if player is trying to move
			if Input.is_action_pressed("Sprint"):
				state_machine.change_state("running")
			elif Input.is_action_pressed("Crouch"):
				state_machine.change_state("crouchwalking")
			else:
				state_machine.change_state("walking")
		else:
			if Input.is_action_pressed("Crouch"):
				state_machine.change_state("crouching")
			else:
				state_machine.change_state("idle")

func _on_body_edge_climb_done() -> void:
	climbDone = true
