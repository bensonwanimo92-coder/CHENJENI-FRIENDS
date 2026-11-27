extends Camera3D
class_name StreetLegendThirdPersonCamera

@export var target: Node3D
@export var follow_offset := Vector3(0.0, 5.8, 7.5)
@export var look_height: float = 1.15
@export var follow_sharpness: float = 5.0

func _process(delta: float) -> void:
	if not is_instance_valid(target):
		return
	var focus := target.global_position + Vector3.UP * look_height
	var desired := target.global_position + target.global_transform.basis * follow_offset
	var weight := 1.0 - exp(-follow_sharpness * delta)
	global_position = global_position.lerp(desired, weight)
	look_at(focus, Vector3.UP)
