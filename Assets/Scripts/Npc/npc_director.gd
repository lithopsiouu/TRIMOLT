class_name NpcDirector extends Node

## Directs Npcs to specific locations.

@onready var wander_timer: Timer = $WanderTimer

@export_category("Idle Settings")
@export var use_wander_timer: bool = true

func _ready() -> void:
	wander_timer.autostart = use_wander_timer
