@tool
extends AnimatableBody3D

@export var angular_speed_deg: float = 90.0
@export var rotation_axis: Vector3 = Vector3.UP
@export var axis_is_local: bool = false
@export var pivot_local_offset: Vector3 = Vector3.ZERO
@export var pivot_node: Node3D
@export var rotation_enabled: bool = true
@export var time_offset: float = 0.0 # milliseconds offset added to synced time

var current_time_ms: float = 0.0
var progress: float = 0.0

var _initial_transform: Transform3D
var _local_time_ms: float = 0.0


func _ready() -> void:
	_initial_transform = global_transform
	if rotation_enabled:
		global_transform = _initial_transform
		_local_time_ms = 0.0
	sync_to_physics = true
	set_process(Engine.is_editor_hint())


func _physics_process(delta: float) -> void:
	_update_rotation(delta)


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		_update_rotation(delta)


func _update_rotation(delta: float) -> void:
	if not rotation_enabled:
		constant_angular_velocity = Vector3.ZERO
		progress = 0.0
		return

	var axis := _get_rotation_axis()
	var angular_speed_rad: float = deg_to_rad(angular_speed_deg)
	if axis == Vector3.ZERO or is_zero_approx(angular_speed_rad):
		_set_transform(_initial_transform)
		constant_angular_velocity = Vector3.ZERO
		progress = 0.0
		return

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

	var elapsed_seconds: float = elapsed_ms * 0.001
	var angle: float = angular_speed_rad * elapsed_seconds
	var rotation_delta := Basis(axis, angle)
	var new_basis := rotation_delta * _initial_transform.basis
	var pivot := _get_pivot_position()
	var rotated_origin := pivot + rotation_delta * (_initial_transform.origin - pivot)
	_set_transform(Transform3D(new_basis.orthonormalized(), rotated_origin))

	var normalized_angle: float = fposmod(angle, TAU)
	progress = normalized_angle / TAU
	constant_angular_velocity = axis * angular_speed_rad


func _set_transform(xform: Transform3D) -> void:
	global_transform = xform


func _get_rotation_axis() -> Vector3:
	var axis := rotation_axis
	if axis.length_squared() == 0.0:
		return Vector3.ZERO
	axis = axis.normalized()
	if axis_is_local:
		axis = (_initial_transform.basis * axis).normalized()
	return axis


func _get_pivot_position() -> Vector3:
	if pivot_node != null and is_instance_valid(pivot_node):
		return pivot_node.global_position
	return _initial_transform.origin + _initial_transform.basis * pivot_local_offset


func _get_current_time_ms() -> Variant:
	if Engine.is_editor_hint():
		return null
	if GGS.CURRENT_TIME != null:
		return GGS.CURRENT_TIME
	return null
