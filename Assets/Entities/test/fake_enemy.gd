extends StaticBody3D

@export var knockback_damp: int = 4 ## Reduce strength of knockback
@export var starting_health: int = 100 ## Only controls the health the fake_enemy starts with.
var health: int = 1
@onready var dead_timer: Timer = $DeadTimer
@onready var hurtbox_collider: CollisionShape3D = $Hurtbox/CollisionShape3D


func _ready() -> void:
	dead_timer.timeout.connect(revive)
	health = starting_health

## Reduces health by amount. Dies if health is greater or equal to 0.
func take_damage(amount: int) -> void:
	health -= amount
	print("\ndamage received: ", amount, "\n[b]", name, " health:[/b] ", health)
	
	if health <= 0:
		die()

## Pushes body back by amount of damage dealt divided by knockback_damp
func do_knockback(hitbox: Hitbox, damage: int) -> void:
	var direction_vec: Vector3 = hitbox.global_position.direction_to(global_position)
	var knockback: Vector3 = direction_vec * (damage / knockback_damp)
	knockback.y = 0 #ignore vertical axis
	global_position += knockback # add knockback to position

## Disables hurtbox collider and starts a death cooldown.
func die() -> void:
	scale.y = 0.4
	hurtbox_collider.disabled = true
	dead_timer.start()

## Returns body to full health and enables hurtbox collider.
func revive() -> void:
	health = starting_health
	scale.y = 1.0
	hurtbox_collider.disabled = false
