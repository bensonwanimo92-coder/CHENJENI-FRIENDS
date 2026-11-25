extends Node3D
class_name StreetLegendChaseTarget

@export var route: Array[Node3D] = []
@export var speed: float = 14.0
@export var waypoint_radius: float = 5.0
@export var keep_ahead_distance: float = 20.0
@export var escape_speed: float = 25.5
var route_index: int = 0
var player_vehicle: Node3D

func _physics_process(delta: float) -> void:
	if route.is_empty():
		return
	var current_speed := speed
	if is_instance_valid(player_vehicle):
		var gap := global_position.distance_to(player_vehicle.global_position)
		# Keep the Range Rover physically ahead without teleporting or ending the pursuit early.
		if gap < keep_ahead_distance:
			current_speed = escape_speed
	var waypoint := route[route_index]
	var direction := waypoint.global_position - global_position
	direction.y = 0.0
	if direction.length() <= waypoint_radius:
		route_index = (route_index + 1) % route.size()
		return
	var desired := atan2(-direction.x, -direction.z)
	rotation.y = rotate_toward(rotation.y, desired, deg_to_rad(100.0) * delta)
	global_position += -global_transform.basis.z * current_speed * delta
