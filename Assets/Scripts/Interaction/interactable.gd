class_name Interactable
extends Area3D

## An [Area3D] that sends its parent [code]activate[/code] or [code]deactivate[/code] signals when colliding
## with an [Interactor]

@export var one_time: bool = false ## Determines if the [Interactable] can only be activated once.
@export var toggle: bool = true ## Determines if the [Interactable] has a [code]true[/code] and [code]false[/code] state.
@export var toggle_state = false ## The state of the [Interactable].[br]Only used if [param toggle] is [code]true[/code].
@export var cooldown: float = 0.0 ## Only used if [param cooldown] is greater than 0.

@onready var timer: Timer

func _init() -> void:
	collision_layer = 4
	collision_mask = 0
	
	#if get_child(0) == null:
		#var col: CollisionShape3D = CollisionShape3D.new()
		#add_child(col)
		#var sphere: SphereShape3D = SphereShape3D.new()
		#sphere.radius = 1.0
		#col.shape = sphere

func _ready() -> void:
	#area_entered.connect(_on_area_entered)
	_config_timer()

## Initialize a [Timer] and its properties
func _config_timer():
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true

func _toggle():
	if timer.time_left > 0:
		return
	
	if toggle_state == false:
		toggle_state = true
		if owner.has_method("activate"):
			owner.activate()
	else:
		toggle_state = false
		if owner.has_method("deactivate"):
			owner.deactivate()
	
	if one_time:
		self.queue_free()
		return
	
	if cooldown > 0.0:
		wait(cooldown)

## Waits for [param seconds]
func wait(seconds: float) -> void:
	timer.start(seconds)
