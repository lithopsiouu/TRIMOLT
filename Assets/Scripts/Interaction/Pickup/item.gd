class_name Item extends Node3D

## Item that can be put into an inventory
@onready var icon: Sprite3D = $Sprite3D

func _ready() -> void:
	icon.visible = false

func activate() -> void:
	disable(true)
	print("item grabbed")

func disable(state: bool) -> void:
	match state:
		true:
			visible = false
			self.process_mode = Node.PROCESS_MODE_DISABLED
		false:
			visible = true
			self.process_mode = Node.PROCESS_MODE_INHERIT
