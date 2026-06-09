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
var _sprint_toggle: bool = false
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
const MIN_STUMBLE_VELOCITY: float = -8.0 ## Minimum [member RigidBody3D.linear_velocity.y] required in order to cause a stumble.
var stumble_time: float = 0.5 ## Duration of stumble in seconds.
var _stumble_timer: SceneTreeTimer
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
var run_speed: float = 2.5
var walk_speed: float = 1.5
var stop_speed: float = 0.6
var jump_velocity: float = 7.2

# Movement
var move_input: Vector2 = Vector2.ZERO ## Direction of movement input
var move_input_influence: float = 1.0

# Camera
var mouse_input: Vector2 = Vector2()
var joy_input: Vector2 = Vector2()
var _cam_input: Vector2 = Vector2()
var max_cam_rot_deg: int = 85
var rand_cam_rot: float = 0.0

# Settings
@export_group("Input Settings")
@export_range(0.0, 1.0, 0.05) var input_deadzone: float = 0.1
@export var toggle_sprint: bool = true
@export_range(0.0, 50.0, 0.25) var view_sensitivity: float = 20.0
@export_range(0.0, 50.0, 0.25) var joy_view_sensitivity: float = 4.5

func _init() -> void:
	_health = _max_health

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
	move_input = Input.get_vector("Left", "Right", "Forward", "Backward", 0.1) * move_input_influence
	
	_update_auto_uncrouch()
	
	_update_can_stumble()
	
	_stumble_process()

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
		_cam_input = mouse_input
	
	if event is InputEventJoypadMotion:
		joy_input = Input.get_vector("cam_look_left","cam_look_right","cam_look_up","cam_look_down")
		_cam_input = joy_input * joy_view_sensitivity
	
	if Input.is_action_just_pressed("Jump") and jumping == false and ground_check.is_colliding():
		jump()
	
	if toggle_sprint == false:
		if Input.is_action_just_pressed("Sprint"):
			sprinting = true
		elif Input.is_action_just_released("Sprint"):
			sprinting = false
	else:
		if Input.is_action_just_pressed("Sprint"):
			_sprint_toggle = !_sprint_toggle
			sprinting = _sprint_toggle
	
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
func stumble(time: float = stumble_time, strength: float = stumble_strength, influence: float = move_input_influence) -> void:
	if can_stumble:
		stumbling = true
		print("stumbling for ", str(stumble_time), " seconds with a strength of ", str(stumble_strength), ".")
		_stumble_timer = _timer(stumble_time)
		
		stumble_strength = clampf(stumble_strength, 0.0, 1.1)
		move_input_influence = stumble_strength
		
		var cam_rot_reduction = 0.5
		var plus_or_minus = -1 if randi() < 0.5 else 1
		rand_cam_rot = stumble_strength * plus_or_minus * cam_rot_reduction
		
		var time_fract = 0.1
		var time_fract_larger = stumble_time * time_fract
		var time_fract_smaller = stumble_time * ( 1 - time_fract)
		
		var tween = get_tree().create_tween()
		tween.tween_property(camera, "rotation", Vector3(0,0,rand_cam_rot), stumble_time * 0.1).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		tween.tween_property(camera, "rotation", Vector3.ZERO, stumble_time * 0.9).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	
	else:
		printerr("Cannot stumble.")

func _stumble_process():
		if stumbling:
			var _stumble_progress = _stumble_timer.time_left / stumble_time ## Goes from 1 to 0.
			var _inverse_stumble_progress = 1 - _stumble_progress ## Goes from 0 to 1.
			
			#print(move_input)
			
			move_input_influence *= _stumble_progress
			
			if _stumble_timer.time_left == 0.0:
				stumbling = false

func jump():
	jumping = true
	apply_impulse(Vector3.UP * jump_velocity)
	print("jumpang bruh")

func get_fall_distance() -> void:
	# get init y fall position and subtract from updating y fall position
	if float_ray.is_colliding() == false:
		fall_height = init_fall_pos.y - self.global_position.y
	
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
	camera_holder.rotation_degrees.x -= _cam_input.y * view_sensitivity * delta
	camera_holder.rotation_degrees.x = clamp(camera_holder.rotation_degrees.x, -max_cam_rot_deg, max_cam_rot_deg)
	head_position.rotation_degrees.y -= _cam_input.x * view_sensitivity * delta
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

func _wait(seconds: float):
	await get_tree().create_timer(seconds).timeout

func _timer(seconds: float) -> SceneTreeTimer:
	return get_tree().create_timer(seconds)
