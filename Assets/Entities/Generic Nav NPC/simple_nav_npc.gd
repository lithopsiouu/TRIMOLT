extends CharacterBody3D

# TO DO:
# DONE: Make agent track player pos for a moment after losing sight for more tracking accuracy

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

@export_category("Navigation")
@export var nav_target_parent: Node3D
@onready var nav_target: Node3D
var nav_target_pos: Vector3
var following: bool = false

@export var use_random_pos: bool = false
@export var use_target_pos: bool = true

@export var speed: float = 4.0
@export var sight_lost_tracking_ticks: int = 1
var tracking_ticks: int = 0

@export_category("Sight")
@export var use_sight: bool = true
@export_range(1, 35) var sight_length: float = 6
@onready var closeDetection: ShapeCast3D = $CloseDetection
@onready var vision_ray: RayCast3D = $VisionRay

@export_category("Rotation")
@export_enum("rotate_to_end_target", "rotate_to_next_path_target", "rotate_to_velocity") var rotation_setting = "rotate_to_next_path_target"
@export var use_y_only: bool = true
@export var use_smooth_turn: bool = true

func _ready() -> void:
	nav_target = nav_target_parent.find_child("Body")
	$VisionArea/CollisionCone.scale.y = sight_length
	#_unstick()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_pressed("ui_accept") and use_random_pos:
		var rand_pos := Vector3.ZERO
		rand_pos.z = randf_range(-5.0, 5.0)
		rand_pos.x = randf_range(-5.0, 5.0)
		navigation_agent_3d.target_position = rand_pos
		#print(str(navigation_agent_3d.is_navigation_finished()))

func _physics_process(delta: float) -> void:
	
	if not navigation_agent_3d.is_navigation_finished():
		var destination = navigation_agent_3d.get_next_path_position()
		var local_destination = destination - global_position
		var direction = Vector3(local_destination.x, 0, local_destination.z).normalized()
		
		_do_transform(destination, direction)
		
		move_and_slide()

func _do_transform(destination: Vector3, direction: Vector3) -> void:
	if rotation_setting == "rotate_to_next_path_target":
		if not use_y_only:
			look_at(destination)
		else:
			if use_smooth_turn:
				rotation.y = _smooth_lerp_angle(destination, false, 10)
			else:
				look_at(Vector3(destination.x, global_position.y, destination.z))
	elif rotation_setting == "rotate_to_end_target":
		if use_y_only:
			if use_smooth_turn:
				rotation.y = _smooth_lerp_angle(navigation_agent_3d.target_position, false, 10)
			else:
				look_at(Vector3(navigation_agent_3d.target_position.x, global_position.y, navigation_agent_3d.target_position.z))
	elif rotation_setting == "rotate_to_velocity":
		if use_smooth_turn:
			rotation.y = _smooth_lerp_angle(velocity, true)
		else:
			look_at(Vector3(global_position.x + velocity.x, global_position.y, global_position.z + velocity.z))
	velocity = direction * speed
	
	if not is_on_floor():
		velocity += get_gravity()
		print("boo hoo im floating")

func _smooth_lerp_angle(targetVec: Vector3, isDirection: bool = false, turnSpeed: float = 20.0) -> float:
	var _lookDir: Vector3
	if not isDirection:
		_lookDir = global_position.direction_to(targetVec)
	else:
		_lookDir = targetVec
	return lerp_angle(rotation.y, atan2( -_lookDir.x, -_lookDir.z), get_process_delta_time() * turnSpeed)

func _on_vision_timer_timeout() -> void:
	var overlaps = $VisionArea.get_overlapping_bodies()
	
	if use_target_pos and closeDetection.is_colliding():
		following = true
		tracking_ticks = sight_lost_tracking_ticks
		nav_target = closeDetection.get_collider(0)
		_update_nav(nav_target)
	
	if overlaps.size() > 0:
		for overlap in overlaps: 
			if overlap is Player:
				var playerPos = overlap.get_parent().find_child("CameraContainer").global_position
				vision_ray.look_at(playerPos, Vector3.UP)
				vision_ray.force_raycast_update()
				
				if $VisionRay.is_colliding():
					var collider = $VisionRay.get_collider()
					
					if collider is Player:
						following = true
						tracking_ticks = sight_lost_tracking_ticks
						_update_nav(collider)
					elif tracking_ticks > 0:
						following = false
						_update_nav(nav_target)
						tracking_ticks -= 1
						print("Tracking outside LOS. ruff ruff")
					else:
						nav_target = null
	elif tracking_ticks > 0:
		following = false
		_update_nav(nav_target)
		tracking_ticks -= 1
		print("Tracking ouside vision cone. ruff ruff")

func _update_nav(newTarget: Node3D):
		if newTarget != null:
			navigation_agent_3d.target_position = newTarget.global_position
			#print("Pathing to target " + str(newTarget.global_position))
		else:
			navigation_agent_3d.target_position = position
			print("No target to path to.")
		nav_target = newTarget

func _on_navigation_finished() -> void:
	nav_target = null
	print("Navigation finished.")
