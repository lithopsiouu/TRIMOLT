extends Node3D

@onready var interactor: Interactor = $Interactor
@onready var interactor_shape: CollisionShape3D = $Interactor/CollisionShape3D
@onready var enable_timer: Timer = $EnableTime
const TEST_3D_BUTTON_PROMPT = preload("res://Assets/UI/test/test_3D_button_prompt.tscn")

func _ready() -> void:
	enable_timer.timeout.connect(_disable_interactor_shape)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Interact"):
		_interact()

func _interact():
	var inter = interactor.interactables
	if inter.size() == 0:
		print("no interactables")
		return
	
	if inter[0].has_method("_toggle"):
		inter[0]._toggle()
	#interactor_shape.disabled = false
	#enable_timer.start()

func _disable_interactor_shape():
	interactor_shape.disabled = true
