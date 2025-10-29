@tool
extends AnimatableBody3D

enum MovementFunction {
	SIN,
	LINEAR
}

enum BackMoveType {
	TELEPORT,
	REVERSE
}

@export var speed: float = 5.0
@export var move_from: Vector3 = Vector3.ZERO
@export var move_to: Vector3 = Vector3.ZERO
@export var move_from_node: Node3D
@export var move_to_node: Node3D
@export var movment_enabled: bool = true
@export var movment_function: MovementFunction = MovementFunction.SIN
@export var back_move_type: BackMoveType = BackMoveType.TELEPORT
@export var time_offset: float = 0.0 # milliseconds offset added to synced time

var current_time_ms: float = 0.0
var progress: float = 0.0

var _local_time_ms: float = 0.0
var _ggs: Node = null
var _previous_position: Vector3 = Vector3.ZERO


func _ready() -> void:
	if movment_enabled:
		global_position = _get_from_position()
		_local_time_ms = 0.0
	sync_to_physics = true
	_previous_position = global_position
	set_process(Engine.is_editor_hint())


func _physics_process(delta: float) -> void:
	_update_movement(delta)


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		_update_movement(delta)


func _update_movement(delta: float) -> void:
	if not movment_enabled:
		constant_linear_velocity = Vector3.ZERO
		_previous_position = global_position
		return

	var previous_pos: Vector3 = _previous_position
	var from_pos = _get_from_position()
	var to_pos = _get_to_position()

	var time_value = _get_current_time_ms()
	if time_value == null:
		_local_time_ms += delta * 1000.0
		current_time_ms = _local_time_ms
	else:
		current_time_ms = float(time_value)
		_local_time_ms = current_time_ms

	var elapsed_ms: float = current_time_ms + time_offset
	if elapsed_ms < 0.0:
		elapsed_ms = 0.0

	var distance: float = from_pos.distance_to(to_pos)
	if speed <= 0.0 or distance <= 0.0:
		global_position = from_pos
		progress = 0.0
		constant_linear_velocity = Vector3.ZERO
		_previous_position = global_position
		return

	var travel_time: float = distance / speed
	if travel_time <= 0.0:
		global_position = from_pos
		progress = 0.0
		constant_linear_velocity = Vector3.ZERO
		_previous_position = global_position
		return

	var elapsed_seconds: float = elapsed_ms * 0.001
	var normalized_time: float = elapsed_seconds / travel_time
	var base_progress: float
	if back_move_type == BackMoveType.TELEPORT:
		base_progress = fposmod(normalized_time, 1.0)
	else:
		var wrapped: float = fposmod(normalized_time, 2.0)
		base_progress = wrapped if wrapped <= 1.0 else 2.0 - wrapped

	var eased_progress: float = base_progress
	match movment_function:
		MovementFunction.LINEAR:
			eased_progress = base_progress
		MovementFunction.SIN:
			eased_progress = 0.5 - 0.5 * cos(base_progress * PI)

	progress = eased_progress
	global_position = from_pos.lerp(to_pos, eased_progress)

	var platform_velocity := Vector3.ZERO
	if delta > 0.0:
		platform_velocity = (global_position - previous_pos) / delta
	constant_linear_velocity = platform_velocity
	_previous_position = global_position


func _get_from_position() -> Vector3:
	return _get_node_position(move_from_node, move_from)


func _get_to_position() -> Vector3:
	return _get_node_position(move_to_node, move_to)


func _get_node_position(node: Node3D, fallback: Vector3) -> Vector3:
	if node != null and is_instance_valid(node):
		return node.global_position
	return fallback


func _get_current_time_ms() -> Variant:
	if Engine.is_editor_hint():
		return null
	if GGS.CURRENT_TIME != null:
		return GGS.CURRENT_TIME
	return null
	
