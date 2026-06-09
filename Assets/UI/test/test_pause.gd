extends Control

var paused: bool = false

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Menu"):
		paused = !paused
		self.visible = paused
		get_tree().paused = paused
