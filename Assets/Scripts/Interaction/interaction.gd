class_name Interaction extends Node3D

## Interaction class. Visualizes interaction

@onready var interactable: Interactable = $Interactable
#const ERROR: Material = preload("res://Assets/Materials/Error.tres")
#const ERROR_GREEN: Material = preload("res://Assets/Materials/Error_Green.tres")

func _ready() -> void:
	var inter = find_child("Interactable")
	
	if inter != null:
		interactable = inter
	else:
		var interactable = Interactable.new()
		add_child(interactable)
		inter = interactable
	
	await interactable.ready

## Activation function.
func activate():
	print("Activated!")

## Deactivation function.
func deactivate():
	print("Deactivated!")
