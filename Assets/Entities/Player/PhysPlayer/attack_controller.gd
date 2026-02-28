extends Node3D
## Handles attacks, attack types, and attack type switching
##
## Parent of all attack types and controls functionality of them.
## Controls the switching of attack types and attack inputs.

## Attack types:
## [b]Unequipped[/b] - Hands will be offscreen. Attacking equips the last used weapon.
## [b]Melee Attack[/b]
## [b]Ranged Attack[/b]
## [b]Special Attack[/b]
const ATTACK_TYPES: Array = [
	"Unequipped",
	"Melee",
	"Ranged",
	"Special"
]

const ATTACK_DAMAGES: Dictionary = {
	ATTACK_TYPES[0]: 0,
	ATTACK_TYPES[1]: 15,
	ATTACK_TYPES[2]: 10,
	ATTACK_TYPES[3]: 20
}

@export var melee_damage_variance:int = 2

@onready var hitbox_melee: Hitbox = $HitboxMelee
@onready var melee: CollisionShape3D = $HitboxMelee/MeleeShape
@onready var melee_cooldown_timer: Timer = $MeleeCooldown

@onready var hitbox_ranged: Hitbox = $HitboxRanged
@onready var ranged: CollisionShape3D = $HitboxRanged/RangedShape
@onready var ranged_cooldown_timer: Timer = $RangedCooldown
@onready var ranged_hit_linger_timer: Timer = $RangedHitLinger

@onready var distance_ray: RayCast3D = $DistanceRay

var attacking: bool = false ## Prevents multiple attacks before the cooldown timer ends.
var equipped_attack:String = "Unequipped"
var last_equipped_attack:String = "Unequipped"

func _ready() -> void:
	melee_cooldown_timer.timeout.connect(enable_melee)
	ranged_cooldown_timer.timeout.connect(enable_ranged)
	ranged_hit_linger_timer.timeout.connect(_return_hit_area)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Primary_Attack"):
		do_primary_attack()
	elif event.is_action_pressed("Secondary_Attack"):
		do_secondary_attack()
	
	if event.is_action_pressed("Swap_Last_Weapon"):
		switch_attack_type(attack_string_to_int(last_equipped_attack))
	
	if event.is_action_pressed("Select_Unequipped_Attack"):
		switch_attack_type(0)
	if event.is_action_pressed("Select_Melee_Attack"):
		switch_attack_type(1)
	if event.is_action_pressed("Select_Ranged_Attack"):
		switch_attack_type(2)
	if event.is_action_pressed("Select_Special_Attack"):
		switch_attack_type(3)

## Function for "regular" or main attacks of attack type
func do_primary_attack() -> void:
	match equipped_attack:
		ATTACK_TYPES[0]: # Unequipped attack
			print("unequipped attack")
		ATTACK_TYPES[1]: # Melee attack
			_do_melee_attack()
		ATTACK_TYPES[2]: # Ranged attack
			_do_ranged_attack()
		ATTACK_TYPES[3]: # Special attack
			_do_special_attack()

## Function for "heavy" or alternative attacks of attack type
func do_secondary_attack() -> void:
	match equipped_attack:
		ATTACK_TYPES[0]: # Unequipped attack
			print("unequipped attack")
		ATTACK_TYPES[1]: # Melee attack
			_do_melee_attack()
		ATTACK_TYPES[2]: # Ranged attack
			_do_ranged_attack()
		ATTACK_TYPES[3]: # Special attack
			_do_ranged_attack()

func _do_melee_attack() -> void:
	if not attacking:
		print("melee attack successful")
		hitbox_melee.damage = ATTACK_DAMAGES.get(ATTACK_TYPES[1]) + randi_range(-melee_damage_variance, melee_damage_variance)
		melee.disabled = false
		attacking = true
		melee_cooldown_timer.start()
	else:
		print_rich("melee attack [color=red][b]unsuccessful[/b][/color]")

func enable_melee() -> void:
	melee.disabled = true
	attacking = false

func _do_ranged_attack() -> void:
	if not attacking:
		var hit: Vector3 = distance_ray.get_collision_point()
		ranged.global_position = hit
		ranged.disabled = false
		attacking = true
		ranged_hit_linger_timer.start()
		ranged_cooldown_timer.start()
		print("ranged attack successful")
	else:
		print_rich("ranged attack [color=red][b]unsuccessful[/b][/color]")

func _return_hit_area() -> void:
	ranged.disabled = true
	ranged.global_position = global_position

func enable_ranged() -> void:
	attacking = false

func _do_special_attack() -> void:
	if not attacking:
		print("special attack successful")
	else:
		print_rich("special attack [color=red][b]unsuccessful[/b][/color]")

func enable_special() -> void:
	pass

## Handles switching of attack types.
func switch_attack_type(type: int) -> void:
	last_equipped_attack = equipped_attack
	equipped_attack = ATTACK_TYPES[type]
	print("\ncurrent atk: ", equipped_attack, "\nlast atk: ", last_equipped_attack)

func attack_string_to_int(attack: String) -> int:
	var attackInt:int = 0
	
	match attack:
		ATTACK_TYPES[0]:
			attackInt = 0
		ATTACK_TYPES[1]:
			attackInt = 1
		ATTACK_TYPES[2]:
			attackInt = 2
		ATTACK_TYPES[3]:
			attackInt = 3
	
	return attackInt
