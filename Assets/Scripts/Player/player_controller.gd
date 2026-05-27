class_name PlayerController
extends RigidBody3D

## A physically-based [PlayerController] that uses a [StateMachine] for movement and attacks.
##
## Uses a [StateMachine] for movement. The [StateMachine] uses the state bools and [ShapeCast3D] nodes.
## Also uses a [StateMachine] for attacks and attack states.

@onready var state_machine_movement: StateMachine = $StateMachineMovement
@onready var ground_check: ShapeCast3D = $GroundCheck
@onready var float_ray: RayCast3D = $FloatRay
@onready var uncrouch_check: ShapeCast3D = $UncrouchCheck

# State bools
var sprinting: bool = false
var crouching: bool = false
var jumping: bool = false
var _can_uncrouch: bool = false
var _crouch_pressed: bool = false
var stumbling: bool = false

# Stats
@export var _max_health: float = 100
var _health: float

# Falling and stumbling
var fall_height: float = 0.0 ## Vertical distance of a fall.
const MIN_LAND_HEIGHT: float = 0.8 ## Minimum [param fall_height] required in order to cause a landing.
const MIN_STUMBLE_VELOCITY: float = -3.0 ## Minimum [member RigidBody3D.linear_velocity.y] required in order to cause a stumble.
var stumble_time: float = 0.5 ## Duration of stumble in seconds.
var stumble_strength: float = 0.8 ## Strength of stumble.
var can_stumble: = false

# Velocity
var target_velocity: float = 0.0
var speed: float = 0.0

var move_input: Vector2 = Vector2.ZERO ## Direction of movement input

# Settings
@export_group("Input Settings")
@export_range(0.0, 1.0, 0.05) var input_deadzone: float = 0.1

func _init() -> void:
	_health = _max_health

func update(delta: float) -> void:
	move_input = Input.get_vector("Left", "Right", "Forward", "Backward", 0.1)
	_can_uncrouch = !uncrouch_check.is_colliding()
	if crouching and _can_uncrouch: 
		if _crouch_pressed == false:
			crouching = false

func _input(event):
	#if event is InputEventMouseMotion:
		#mouse_input = event.relative
	
	if Input.is_action_just_pressed("Sprint"):
		sprinting = true
	elif Input.is_action_just_released("Sprint"):
		sprinting = false
	
	if Input.is_action_just_pressed("Crouch"):
		_crouch_pressed = true
	elif Input.is_action_just_released("Crouch"):
		_crouch_pressed = false

## Reduces player health by [param damage].
func take_damage(damage: float) -> void:
	damage = abs(damage) # ensure damage is a positive number
	_health -= damage
	if _health <= -1.0:
		die()

## Increases health by [param health].
func heal(amount: float) -> void:
	amount = abs(amount) # ensure health is a positive number
	_health = clampf(_health + amount, _health, _max_health)

## Called when [member PlayerController._health] is lesser than [code]0[/code].
func die() -> void:
	pass

## Cause camera shake with [param strength] and some input reduction with [param influence] for [param time].
func stumble(time: float = stumble_time, strength: float = stumble_strength, influence: float = 0.8) -> void:
	stumbling = true
	print("stumbling for ", str(stumble_time), " seconds with a strength of ", str(stumble_strength), ".")
