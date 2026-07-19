extends Node3D

@onready var interactor: Interactor = $Interactor
var interactables
@onready var interactor_shape: CollisionShape3D = $Interactor/CollisionShape3D
@onready var enable_timer: Timer = $EnableTime

@onready var prompt: Panel = $Prompt
@onready var prompt_text: Label = $Prompt/Label

var camera: Camera3D

func _ready() -> void:
	interactables = interactor.interactables
	enable_timer.timeout.connect(_disable_interactor_shape)
	prompt_text.text = get_key_name_for_action("Interact")
	
	camera = get_viewport().get_camera_3d()

func get_key_name_for_action(action_name: String) -> String:
	# Get all events assigned to the action
	var events = InputMap.action_get_events(action_name)
	
	for event in events:
		# Check if the event is a keyboard key
		if event is InputEventKey:
			# Returns a clean, localized string of the key
			return event.as_text_physical_keycode() 
			
	return "No key assigned"

func _process(delta: float) -> void:
	if interactables.size() > 0:
		prompt.visible = true
		track_interaction_prompt_onscreen()
	else:
		prompt.visible = false

func track_interaction_prompt_onscreen() -> void:
	var interactable = interactables[0].global_transform.origin
	var screen_pos = camera.unproject_position(interactable)
	var viewport_size = get_viewport().size
	var control_size = prompt.size # Or half the size if its pivot is centered

	# Keep on-screen with margin
	prompt.position.x = clamp(screen_pos.x, control_size.x, viewport_size.x - control_size.x)
	prompt.position.y = clamp(screen_pos.y, control_size.y, viewport_size.y - control_size.y)


func track_interaction_prompt_offscreen() -> void:
	var interactable = interactables[0].global_transform.origin
	var screen_pos = camera.unproject_position(interactable)
	var viewport_size = get_viewport().size
	var screen_center = viewport_size / 2.0

	# Calculate direction from the center of the screen
	var dir = screen_pos - screen_center

	# Find the aspect ratio of the viewport
	var aspect_ratio = viewport_size.x / viewport_size.y

	# Calculate the scale factor to reach the screen edge
	var bounds = screen_center - Vector2(5, 5) # Optional: margin so the icon doesn't clip the edge
	var scale_x = abs(bounds.x / dir.x)
	var scale_y = abs(bounds.y / dir.y)
	var scale = min(scale_x, scale_y)

	# Final clamped position
	var edge_pos = screen_center + (dir * scale)
	prompt.position = edge_pos


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Interact"):
		_interact()

func _interact():
	if interactables.size() == 0:
		print("no interactables")
		return
	
	if interactables[0].has_method("_toggle"):
		interactables[0]._toggle(owner)
	#interactor_shape.disabled = false
	#enable_timer.start()

func _disable_interactor_shape():
	interactor_shape.disabled = true
