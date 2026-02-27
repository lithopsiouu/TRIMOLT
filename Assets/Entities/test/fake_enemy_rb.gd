extends RigidBody3D

@export var knockback_power: int = 4 ## Strength of knockback.
@export var vertical_knockback: float = 0.5 ## Amount of vertical knockback.
@export var starting_health: int = 100 ## Health the fake_enemy starts with.
var health: int = 1
@onready var dead_timer: Timer = $DeadTimer
@onready var hurtbox_collider: CollisionShape3D = $Hurtbox/CollisionShape3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D


func _ready() -> void:
	dead_timer.timeout.connect(revive)
	health = starting_health

## Reduces health by amount. Dies if health is greater or equal to 0.
func take_damage(amount: int) -> void:
	health -= amount
	print_rich("\ndamage received: ", amount, "\n[b]", name, " health:[/b] ", health)
	
	if health <= 0:
		die()

func do_knockback(hitbox: Hitbox, damage: int) -> void:
	var distance = hitbox.global_position.distance_to(global_position)
	var direction_vec: Vector3 = hitbox.global_position.direction_to(global_position)
	direction_vec.y = vertical_knockback #set vertical knockback base
	var knockback = direction_vec * (distance * knockback_power)
	apply_central_impulse(knockback)

func die() -> void:
	collision_shape_3d.scale.y = 0.4
	mesh_instance_3d.scale.y = 0.4
	hurtbox_collider.disabled = true
	dead_timer.start()

func revive() -> void:
	health = starting_health
	collision_shape_3d.scale.y = 1.0
	mesh_instance_3d.scale.y = 1.0
	hurtbox_collider.disabled = false
