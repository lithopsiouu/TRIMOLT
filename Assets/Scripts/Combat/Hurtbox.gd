class_name Hurtbox
extends Area3D

## An [Area3D] that detects a [Hitbox]. The [Hurtbox] then takes the [Hitbox.damage] and passes it to a
## [code]"take_damage"[/code] owner method.

@onready var hurt_timer: Timer = $"../HurtTimer"
var ignored_areas: Array = [Hitbox]
var current_hitbox: Hitbox = null

func _ready() -> void:
	collision_layer = 0
	collision_mask = 8
	area_entered.connect(_on_area_entered)

## See if hurt cooldown is active, and if not, begin cooldown
func hurt_cooldown() -> bool:
	var cooldown_active = false
	if hurt_timer.time_left > 0:
		cooldown_active = true
	else:
		cooldown_active = false
		hurt_timer.start()
	return cooldown_active

func compare_hitbox_rid(hitbox: Hitbox):
	return current_hitbox.get_rid() == hitbox.get_rid()

func _on_area_entered(hitbox: Hitbox) -> void:
	if hitbox == null:
		return
	
	current_hitbox = hitbox
	if ignored_areas.find_custom(compare_hitbox_rid.bind()) != -1:
		return
	
	ignored_areas.append(hitbox)
	
	if hurt_cooldown() == true:
		return
	else:
		if owner.has_method("take_damage"):
			owner.take_damage(hitbox.damage)
		
		if owner.has_method("do_knockback"):
			owner.do_knockback(hitbox, hitbox.damage)

## Clear all ignored Hitbox elements when [param HurtTimer] ends
func _on_hurt_timer_timeout() -> void:
	ignored_areas.clear()
