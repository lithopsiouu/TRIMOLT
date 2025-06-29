class_name StateMachine extends Node

@export var initial_state: State

var currentState: State
var states = {}

func _ready() -> void:
	for child in get_children():
		if child is State:
			child.state_machine = self
			states[child.name.to_lower()] = child
	if initial_state:
		initial_state.enter()
		currentState = initial_state

func _process(delta: float) -> void:
	if currentState:
		currentState.update(delta)

func _physics_process(delta: float) -> void:
	if currentState:
		currentState.physics_update(delta)

func change_state(newStateName: String) -> void:
	var newState: State = states.get(newStateName.to_lower())
	
	assert(newState, "State not found: " + newStateName)
	
	if currentState:
		currentState.exit()
	
	newState.enter()
	
	currentState = newState
	print(str(newStateName))
