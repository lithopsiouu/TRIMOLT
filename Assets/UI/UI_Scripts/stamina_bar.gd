extends ProgressBar

var _time_to_hide: bool = false

func _on_value_changed(value: float) -> void:
	print("stamina bar activity")
	_time_to_hide = false
	modulate.a = move_toward(modulate.a, 1, get_process_delta_time() * 5)
	$HideTimer.start()

func _on_hide_timer_timeout() -> void:
	print("stamina bar hiding time")
	_time_to_hide = true

func _process(delta: float) -> void:
	if _time_to_hide:
		modulate.a = move_toward(modulate.a, 0, get_process_delta_time() * 2)
