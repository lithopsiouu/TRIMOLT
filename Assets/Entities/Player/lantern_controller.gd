extends Node3D

@onready var lantern: OmniLight3D = $Lantern
@onready var lantern_target: Node3D = $LanternTarget
@export var lantern_toggle = false
const FOLLOW_SPEED:float = 8

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Flashlight"):
		lantern_toggle = !lantern_toggle
		toggle_flashlight(lantern_toggle)

func _physics_process(delta: float) -> void:
	lantern.global_position = lantern.global_position.lerp(lantern_target.global_position, delta * FOLLOW_SPEED)

func toggle_flashlight(mode: bool):
	lantern.visible = mode
	print(str(mode))
