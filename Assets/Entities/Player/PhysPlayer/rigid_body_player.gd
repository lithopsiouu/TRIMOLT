extends RigidBody3D

@export var jump_velocity = 15
@export var standing_float_strength = 90
@export var crouching_float_strength = 38
@export var float_spring_damper = 1.0
var spring_rest_offset = 0.32
@export var acceleration = 18.0
@export var walk_speed = 2.0
@export var run_speed = 3.5
@export_range (0.1, 1.0) var stop_speed = 0.9

var velocity = Vector3()

var mouse_input = Vector2()

@onready var head = $Head
@onready var camera: Camera3D = $Head/PlayerCamera
@onready var collider: CollisionShape3D = $Collider
@onready var mesh: MeshInstance3D = $Mesh
@onready var feet: ShapeCast3D = $Feet
@onready var height_contrl: RayCast3D = $HeightControl
@onready var above_head_check: ShapeCast3D = $AboveHeadCheck
@onready var uncrouch_check: ShapeCast3D = $Head/UncrouchCheck
@onready var disbl_feet_timr: Timer = $DisableFeet
@onready var enabl_jump_timr: Timer = $EnableJump

@export var view_sensitivity = 10.0

var is_on_floor = false
var jumping = false
var canJump = true
var crouching = false
var sprinting = false

var move_input
var standing_cam_height = 1.05
var standing_collider_height = 0.7

var crouching_cam_height = 0.66
var crouching_collider_scale = 0.4
var crouching_collider_height = 0.4
var crouch_speed = 1.8
var uncrouch_speed = 1.2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	linear_damp = 1.0
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	is_on_floor = false
	constant_force.y = 0
	
	if feet.is_colliding():
		is_on_floor = true
		jumping = false
		force_body_up()
	
	move_input = Input.get_vector("Left", "Right", "Forward", "Backward")
	var dir = Vector3(move_input.x, 0, move_input.y)
	velocity = dir * acceleration 
	if move_input.length() > 0.2:
		apply_central_force(velocity.rotated(Vector3.UP, deg_to_rad(head.rotation_degrees.y)))
		var speed: float
		if sprinting:
			speed = run_speed
		else:
			speed = walk_speed
		
		var horizontal_velocity := Vector2(linear_velocity.x, linear_velocity.z)
		var clamped_velocity := horizontal_velocity.limit_length(speed)
		linear_velocity.x = clamped_velocity.x
		linear_velocity.z = clamped_velocity.y
	elif not is_on_floor:
		constant_force.x = 0
		constant_force.z = 0
	else:
		constant_force.x = 0
		constant_force.z = 0
		linear_velocity.x = linear_velocity.x * stop_speed
		linear_velocity.z = linear_velocity.z * stop_speed
	
	camera.rotation_degrees.x -= mouse_input.y * view_sensitivity * delta
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -85, 85)
	head.rotation_degrees.y -= mouse_input.x * view_sensitivity * delta
	mouse_input = Vector2.ZERO
	

func _process(delta: float) -> void:
	if Input.is_action_pressed("Crouch"): #add "crawling" check for if capsule is touching ground
		_crouch(delta)
	elif crouching and uncrouch_check.is_colliding():
		_crouch(delta)
	else:
		_uncrouch(delta)
	

func _crouch(delta: float) -> void:
	crouching = true
	head.position.y = move_toward(head.position.y, crouching_cam_height, delta * crouch_speed)
	collider.position.y = move_toward(collider.position.y, crouching_collider_height, delta * crouch_speed)
	mesh.position.y = move_toward(mesh.position.y, crouching_collider_height, delta * crouch_speed)
		
	collider.scale.y = move_toward(collider.scale.y, crouching_collider_scale, delta)
	mesh.scale.y = move_toward(mesh.scale.y, crouching_collider_scale, delta)

func _uncrouch(delta: float) -> void:
	crouching = false
	head.position.y = move_toward(head.position.y, standing_cam_height, delta * uncrouch_speed)
	collider.position.y = move_toward(collider.position.y, standing_collider_height, delta * uncrouch_speed)
	mesh.position.y = move_toward(mesh.position.y, standing_collider_height, delta * uncrouch_speed)
		
	collider.scale.y = move_toward(collider.scale.y, 1.0, delta * uncrouch_speed)
	mesh.scale.y = move_toward(mesh.scale.y, 1.0, delta * uncrouch_speed)

func _input(event):
	if event is InputEventMouseMotion:
		mouse_input = event.relative
	
	if Input.is_action_pressed("Sprint"):
		sprinting = true
	else:
		sprinting = false
	
	if Input.is_action_pressed("Jump") and is_on_floor and canJump and not above_head_check.is_colliding():
		jump()

func force_body_up(): #add float strength change for declines(?)
	var other_vel = Vector3.ZERO
	var hit_body = height_contrl.get_collider()
	
	if hit_body != null and hit_body.get("linear_velocity") != null:
		other_vel = hit_body.get("linear_velocity")
	
	var ray_dir_vel = Vector3.DOWN.dot(linear_velocity)
	var other_dir_vel = Vector3.DOWN.dot(other_vel)
	
	var rel_vel = ray_dir_vel - other_dir_vel
	
	var dist_to_ground = (position.distance_to(height_contrl.get_collision_point()) -spring_rest_offset)
	
	var float_strength: float
	if crouching:
		float_strength = crouching_float_strength
	else:
		float_strength = standing_float_strength
	
	var spring_force = (dist_to_ground * float_strength) - (rel_vel * float_spring_damper)
	
	add_constant_force(Vector3.DOWN * spring_force)
	
	if hit_body != null and hit_body.is_class("RigidBody3D"):
		hit_body.apply_force(Vector3.DOWN * -spring_force, height_contrl.get_collision_point())

func jump():
	apply_impulse(Vector3.UP * jump_velocity)
	is_on_floor = false
	jumping = true
	canJump = false
	disable_feet()

func disable_feet():
	feet.enabled = false
	disbl_feet_timr.start()

func _on_disable_feet_timeout() -> void:
	feet.enabled = true
	enabl_jump_timr.start()

func _on_enable_jump_timeout() -> void:
	canJump = true
