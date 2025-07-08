extends ProgressBar

var _time_to_hide: bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _time_to_hide:
		modulate.a = move_toward(modulate.a, 0, get_process_delta_time() * 2)


func _on_hide_timer_timeout() -> void:
	print("health bar hiding time")
	_time_to_hide = true


func _on_value_changed(value: float) -> void:
	_time_to_hide = false
	modulate.a = move_toward(modulate.a, 1, get_process_delta_time() * 5)
	$HideTimer.start()
