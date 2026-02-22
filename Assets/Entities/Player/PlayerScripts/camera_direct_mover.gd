extends Camera3D

@export var followTarget: Player
@export var stateMachine: StateMachine
@export var useVelRotation: bool = true
@export var useVelZoom: bool = true
@export var useViewBob: bool = true
var timeMult: float = 8
var velZoomScale: float = 3
var zoomed: bool = false
var defaultFov: float
var posReduction: float = 4
var targetRotScale: float = 1.2

var time: float
var bobFreq_v: float = 1
var bobCRWalkFreq_v: float = 4
var bobWalkFreq_v: float = 8
var bobRunFreq_v: float = 14
var bobMagnitude_v: float = 0.03
var bobMagnitude_h: float = 0.03
var bobPhase := 0.0

func _ready() -> void:
	bobFreq_v = bobWalkFreq_v
	defaultFov = fov

func _input(event: InputEvent) -> void:
	# zooms camera based on scrollwheel input
	if event is InputEventMouseButton:
		if Input.is_action_pressed("scroll_up") || Input.is_action_pressed("scroll_down"):
			if Input.get_axis("scroll_down", "scroll_up") > 0.5:
				var tween = get_tree().create_tween()
				tween.tween_property(self, "fov", 40, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC) # zoom in
				await tween.finished
				zoomed = true
			else:
				var tween = get_tree().create_tween()
				tween.tween_property(self, "fov", 86, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK) # zoom out
				await tween.finished
				zoomed = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta * float(followTarget.is_on_floor())
	if useVelRotation:
		rotation_degrees.z = rotate_toward(rotation_degrees.z, -followTarget.input_dir.normalized().x * targetRotScale, delta * timeMult)
	if useViewBob:
		_do_viewBob(delta)
	if useVelZoom and not zoomed:
		var fovVel: float = defaultFov + (followTarget.velocity.length() * velZoomScale)
		fovVel = fovVel if fovVel > 92 else defaultFov # force fovVel to be default if smaller than condition
		if fov <= fovVel:
			fov = move_toward(fov, fovVel, delta * 10)
		else:
			fov = move_toward(fov, defaultFov, delta * 30)
	#print(str(fov))

func _do_viewBob(delta: float):
	if stateMachine:
		if stateMachine.currentState == stateMachine.states.get("edgeclimbing"):
			#debug:
			#print("Camera in edge climb")
			pass
		elif stateMachine.currentState == stateMachine.states.get("running"):
			bobPhase += delta * bobRunFreq_v
			position.y = _set_sine_y()
			position.x = _set_sine_x()
		elif stateMachine.currentState == stateMachine.states.get("crouchwalking"):
			bobPhase += delta * bobCRWalkFreq_v
			position.y = _set_sine_y()
			position.x = _set_sine_x()
		else:
			bobPhase += delta * bobWalkFreq_v
			position.y = _set_sine_y()
			position.x = _set_sine_x()

func _set_sine_y():
	var targetVel_xy: Vector2 = Vector2(followTarget.velocity.x,followTarget.velocity.z)
	return sin(bobPhase) * bobMagnitude_v * targetVel_xy.length()
	
func _set_sine_x():
	var targetVel_xy: Vector2 = Vector2(followTarget.velocity.x,followTarget.velocity.z)
	return cos(bobPhase / 2) * bobMagnitude_h * targetVel_xy.length()
