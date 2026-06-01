class_name StateMachine extends Node

## Class for a [StateMachine].

@export var initial_state: State

var current_state: State ## Current state the [StateMachine] is in.
var last_state: State ## Last state the [StateMachine] was in.
var states = {} ## All children that are a [State]

func _ready() -> void:
	for child in get_children():
		if child is State:
			child.state_machine = self
			states[child.name.to_lower()] = child
	if initial_state:
		initial_state.enter()
		current_state = initial_state

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

## Change the [param current_state] to [param new_state_name]
func change_state(new_state_name: String) -> void:
	var new_state: State = states.get(new_state_name.to_lower())
	
	assert(new_state, "State not found: " + new_state_name)
	
	if current_state:
		current_state.exit()
	
	last_state = current_state
	
	new_state.enter()
	
	current_state = new_state
	print(str(new_state_name))
