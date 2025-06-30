extends Camera3D

@export var followTarget: Player
@export var stateMachine: StateMachine
@export var useVelRotation: bool = true
@export var useViewBob: bool = true
var timeMult: float = 8
var posReduction: float = 4
var targetRotScale: float = 1.2

var time: float
var bobFreq_v: float = 1
var bobCRWalkFreq_v: float = 4
var bobWalkFreq_v: float = 8
var bobRunFreq_v: float = 14
var bobMagnitude_v: float = 0.03
var bobPhase := 0.0

func _ready() -> void:
	bobFreq_v = bobWalkFreq_v

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta
	if useVelRotation:
		rotation_degrees.z = rotate_toward(rotation_degrees.z, -followTarget.input_dir.normalized().x * targetRotScale, delta * timeMult)
	if useViewBob:
		if stateMachine:
			if stateMachine.currentState == stateMachine.states.get("edgeclimbing"):
				print("yea")
				time = 0
			elif stateMachine.currentState == stateMachine.states.get("running"):
				bobPhase += delta * bobRunFreq_v
				position.y = _set_sine()
			elif stateMachine.currentState == stateMachine.states.get("crouchwalking"):
				bobPhase += delta * bobCRWalkFreq_v
				position.y = _set_sine()
			else:
				bobPhase += delta * bobWalkFreq_v
				position.y = _set_sine()

func _set_sine():
	var targetVel_xy: Vector2 = Vector2(followTarget.velocity.x,followTarget.velocity.z)
	return sin(bobPhase) * bobMagnitude_v * targetVel_xy.length()
