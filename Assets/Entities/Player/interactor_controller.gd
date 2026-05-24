extends Node3D

@onready var interactor_shape: CollisionShape3D = $Interactor/CollisionShape3D
@onready var enable_timer: Timer = $EnableTime

func _ready() -> void:
	enable_timer.timeout.connect(_disable_interactor_shape)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact"):
		_interact()

func _interact():
	interactor_shape.disabled = false
	enable_timer.start()

func _disable_interactor_shape():
	interactor_shape.disabled = true
