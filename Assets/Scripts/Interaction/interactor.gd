class_name Interactor
extends Area3D

## An [Area3D] that only interacts with [Interactables].

var interactables: Array = []

func _init() -> void:
	collision_layer = 0
	collision_mask = 4

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(interactable: Interactable) -> void:
	print(interactable)
	interactables.insert(0, interactable)

func _on_area_exited(interactable: Interactable) -> void:
	interactables.erase(interactable)
