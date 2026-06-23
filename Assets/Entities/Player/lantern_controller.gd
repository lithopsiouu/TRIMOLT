extends Node3D

@onready var lantern: OmniLight3D = $Lantern
@onready var lantern_target: Node3D = $LanternTarget
@export var lantern_toggle = false
const FOLLOW_SPEED: float = 9
const ROTATION_SPEED: float = 6

func _ready() -> void:
	set_flashlight(lantern_toggle)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Flashlight"):
		lantern_toggle = !lantern_toggle
		set_flashlight(lantern_toggle)

func _physics_process(delta: float) -> void:
	lantern_target.look_at(self.global_position)
	lantern.global_position = lantern.global_position.lerp(lantern_target.global_position, delta * FOLLOW_SPEED)
	lantern.global_rotation = lantern.global_rotation.lerp(lantern_target.global_rotation, delta * ROTATION_SPEED)

func set_flashlight(mode: bool):
	lantern.visible = mode
	print(str(mode))
