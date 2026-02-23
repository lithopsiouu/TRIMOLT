extends RigidBody3D

@export var jump_velocity = 15
@export var float_spring_strength = 25
@export var float_spring_damper = 1.0
var spring_rest_offset = 0.4
@export var speed = 18.0
@export var max_speed = 2.0
@export_range (0.1, 1.0) var stop_speed = 0.9

var velocity = Vector3()

var mouse_input = Vector2()

@onready var head = $Head
@onready var camera: Camera3D = $Head/PlayerCamera
@onready var collider: CollisionShape3D = $Collider
@onready var feet: ShapeCast3D = $Feet
@onready var height_contrl: RayCast3D = $HeightControl
@onready var disbl_feet_timr: Timer = $DisableFeet
@onready var enabl_jump_timr: Timer = $EnableJump

@export var view_sensitivity = 10.0
var is_on_floor = false
var jumping = false
var canJump = true
var move_input

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
	velocity = dir * speed 
	if move_input.length() > 0.2:
		apply_central_force(velocity) # add equation to "rotate" velocity with camera view
		linear_velocity.x = clamp(linear_velocity.x, -max_speed, max_speed)
		linear_velocity.z = clamp(linear_velocity.z, -max_speed, max_speed)
	elif not is_on_floor:
		constant_force.x = 0
		constant_force.z = 0
	else:
		constant_force.x = 0
		constant_force.z = 0
		linear_velocity.x = linear_velocity.x * stop_speed
		linear_velocity.z = linear_velocity.z * stop_speed
	
	camera.rotation_degrees.x -= mouse_input.y * view_sensitivity * delta
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -80, 80)
	head.rotation_degrees.y -= mouse_input.x * view_sensitivity * delta
	mouse_input = Vector2.ZERO
	
	if Input.is_action_pressed("Jump") and is_on_floor and canJump:
		jump()

func _input(event):
	if event is InputEventMouseMotion:
		mouse_input = event.relative

func force_body_up():
	var other_vel = Vector3.ZERO
	var hit_body = height_contrl.get_collider()
	
	if hit_body != null and hit_body.get("linear_velocity") != null:
		other_vel = hit_body.get("linear_velocity")
	
	var ray_dir_vel = Vector3.DOWN.dot(linear_velocity)
	var other_dir_vel = Vector3.DOWN.dot(other_vel)
	
	var rel_vel = ray_dir_vel - other_dir_vel
	
	var dist_to_ground = (position.distance_to(height_contrl.get_collision_point()) -spring_rest_offset) #position offset from height_contrl
	
	var spring_force = (dist_to_ground * float_spring_strength) - (rel_vel * float_spring_damper)
	
	add_constant_force(Vector3.DOWN * spring_force)
	
	if hit_body != null:
		hit_body

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
