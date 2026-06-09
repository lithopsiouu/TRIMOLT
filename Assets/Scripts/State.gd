class_name State extends Node

var state_machine: StateMachine

func enter() -> void:
	pass

func exit() -> void:
	pass

## Called in the [method StateMachine._process] function.
func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func wait(seconds: float):
	await get_tree().create_timer(seconds).timeout
