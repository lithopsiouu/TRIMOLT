class_name Interactor
extends Area3D

## An [Area3D] that only interacts with [Interactables].

func _init() -> void:
	collision_layer = 4
	collision_mask = 0
