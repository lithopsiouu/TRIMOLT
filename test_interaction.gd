extends Node3D

## Interaction test. Visualizes interaction

@onready var button: MeshInstance3D = $Button
@onready var interactable: Interactable = $Interactable
const ERROR: Material = preload("res://Assets/Materials/Error.tres")
const ERROR_GREEN: Material = preload("res://Assets/Materials/Error_Green.tres")

func _ready() -> void:
	await interactable.ready
	
	set_state(interactable.toggle_state)

## Turn [param button] [code]green[/code].
func activate():
	set_state(true)
	print("Activated!")

## Turn [param button] [code]red[/code].
func deactivate():
	set_state(false)
	print("Deactivated!")

## Using [param state], change material color to [code]red[/code] or [code]green[/code].
func set_state(state: bool):
	match state:
		true:
			set_material(1)
		false:
			set_material(0)

## use [code]0[/code] for [code]red[/code] and [code]1[/code] for [code]green[/code].
func set_material(type: int):
	match type:
		0:
			button.set_surface_override_material(0, ERROR)
		1:
			button.set_surface_override_material(0, ERROR_GREEN)
