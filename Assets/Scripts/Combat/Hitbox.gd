class_name Hitbox
extends Area3D

## An [Area3D] that is detected by a [Hurtbox].

@export var damage: int = 10 ## Damage of Hitbox as [int]

func _init() -> void:
	collision_layer = 8
	collision_mask = 0
