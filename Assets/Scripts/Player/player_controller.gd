class_name PlayerController
extends RigidBody3D

## A physically-based [PlayerController] that uses a [StateMachine] for movement and attacks.
##
## Uses a [StateMachine] for movement. The [StateMachine] uses the state bools and [ShapeCast3D] nodes.
## Also uses a [StateMachine] for attacks and attack states.

# Node access
@onready var state_machine_movement: StateMachine = $StateMachineMovement
@onready var camera: Camera3D = $HeadPosition/CameraHolder/PlayerCamera
@onready var camera_holder: Node3D = $HeadPosition/CameraHolder
@onready var head_position: Node3D = $HeadPosition
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
var init_fall_pos: Vector3 = Vector3()
const MIN_LAND_HEIGHT: float = 0.5 ## Minimum [param fall_height] required in order to cause a landing.
const MIN_STUMBLE_VELOCITY: float = -10.0 ## Minimum [member RigidBody3D.linear_velocity.y] required in order to cause a stumble.
var stumble_time: float = 0.5 ## Duration of stumble in seconds.
var stumble_strength: float = 0.8 ## Strength of stumble.
var can_stumble: = false

# Floating
var spring_rest_offset: float = 0.9
var standing_float_strength: float = 100.0
var spring_damper: float = 6

# Velocity
var target_velocity: float = 0.0
var speed: float = 0.0
var acceleration: float = 8.0
var run_speed: float = 2.0
var walk_speed: float = 1.0
var stop_speed: float = 0.8
var jump_velocity: float = 8.0

var move_input: Vector2 = Vector2.ZERO ## Direction of movement input

# Camera
var mouse_input:Vector2 = Vector2()
var max_cam_rot_deg: int = 85

# Settings
@export_group("Input Settings")
@export_range(0.0, 1.0, 0.05) var input_deadzone: float = 0.1
@export_range(0.0, 50.0, 0.25) var view_sensitivity: float = 20.0

func _init() -> void:
	_health = _max_health

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
	move_input = Input.get_vector("Left", "Right", "Forward", "Backward", 0.1)
	
	_update_auto_uncrouch()
	
	_update_can_stumble()

func _physics_process(delta: float) -> void:
	constant_force.y = 0
	_rotate_cam(delta)
	_player_input_force()
	
	if float_ray.is_colliding():
		force_body_up()
	
	if self.linear_velocity.y < 0:
		get_fall_distance()

func _input(event):
	if event is InputEventMouseMotion:
		mouse_input = event.relative
	
	if Input.is_action_just_pressed("Jump"):
		jump()
	
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

## Updates [param can_stumble] to be [code]true[/code] when grounded using [param ground_check].
func _update_can_stumble() -> void:
	if ground_check.is_colliding() == false:
		can_stumble = false
	else:
		can_stumble = true

## Updates [param crouching] to be [code]false[/code] when not [param crouching] and [param _can_uncrouch] is [code]true[/code].[br]
## Also updates [param _can_uncrouch] to be the opposite of [param uncrouch_check][code].is_colliding()[/code].
func _update_auto_uncrouch() -> void:
	_can_uncrouch = !uncrouch_check.is_colliding()
	
	if crouching and _can_uncrouch: 
		if _crouch_pressed == false:
			crouching = false

## Cause camera shake with [param strength] and some input reduction with [param influence] for [param time].
func stumble(time: float = stumble_time, strength: float = stumble_strength, influence: float = 0.8) -> void:
	if can_stumble:
		stumbling = true
		print("stumbling for ", str(stumble_time), " seconds with a strength of ", str(stumble_strength), ".")
	
	else:
		printerr("Cannot stumble.")

func jump():
	jumping = true
	apply_impulse(Vector3.UP * jump_velocity)

func get_fall_distance() -> void:
	# get init y fall position and subtract from updating y fall position
	if float_ray.is_colliding() == false:
		fall_height = init_fall_pos.y - self.global_position.y
		print(fall_height)
	
func force_body_up(): #add float strength change for declines(?)
	var other_vel = Vector3.ZERO
	var hit_body = float_ray.get_collider()
	
	if hit_body != null and hit_body.get("linear_velocity") != null:
		other_vel = hit_body.get("linear_velocity")
	
	var ray_dir_vel = Vector3.DOWN.dot(linear_velocity)
	var other_dir_vel = Vector3.DOWN.dot(other_vel)
	
	var rel_vel = ray_dir_vel - other_dir_vel
	
	var dist_to_ground = (global_position.distance_to(float_ray.get_collision_point()) - spring_rest_offset)
	
	var float_strength: float
	if crouching:
		#float_strength = crouching_float_strength
		pass
	else:
		float_strength = standing_float_strength
	
	var spring_force = (dist_to_ground * float_strength) - (rel_vel * spring_damper)
	
	add_constant_force(Vector3.DOWN * spring_force)
	
	if hit_body != null and hit_body.is_class("RigidBody3D"):
		hit_body.apply_force(Vector3.DOWN * -spring_force, float_ray.get_collision_point())

func _rotate_cam(delta: float) -> void:
	camera_holder.rotation_degrees.x -= mouse_input.y * view_sensitivity * delta
	camera_holder.rotation_degrees.x = clamp(camera_holder.rotation_degrees.x, -max_cam_rot_deg, max_cam_rot_deg)
	head_position.rotation_degrees.y -= mouse_input.x * view_sensitivity * delta
	mouse_input = Vector2.ZERO

func _player_input_force() -> void:
	move_input = Input.get_vector("Left", "Right", "Forward", "Backward")
	var dir = Vector3(move_input.x, 0, move_input.y)
	var velocity = dir * acceleration 
	
	if move_input.length() > 0:
		var speed: float
		
		apply_central_force(velocity.rotated(Vector3.UP, deg_to_rad(head_position.rotation_degrees.y)))
		
		if sprinting:
			speed = run_speed
			
		else:
			speed = walk_speed
		
		var horizontal_velocity := Vector2(linear_velocity.x, linear_velocity.z)
		var clamped_velocity := horizontal_velocity.limit_length(speed)
		
		linear_velocity.x = clamped_velocity.x
		linear_velocity.z = clamped_velocity.y
		
	elif ground_check.is_colliding() == false:
		constant_force.x = 0
		constant_force.z = 0
	else:
		constant_force.x = 0
		constant_force.z = 0
		linear_velocity.x = linear_velocity.x * stop_speed
		linear_velocity.z = linear_velocity.z * stop_speed
