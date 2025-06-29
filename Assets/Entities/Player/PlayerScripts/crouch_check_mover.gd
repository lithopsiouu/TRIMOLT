extends ShapeCast3D

@onready var body: Player = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	top_level = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = body.global_position + Vector3(0, 0.5, 0)
