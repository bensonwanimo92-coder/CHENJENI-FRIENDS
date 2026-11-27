extends CharacterBody3D
class_name StreetLegendVehicleController

@export var acceleration: float = 12.0
@export var braking: float = 18.0
@export var max_speed: float = 24.0
@export var steering_degrees: float = 72.0
@export var lateral_grip: float = 5.0
@export var gravity: float = 9.8
var throttle: float = 0.0
var steering: float = 0.0
var brake_pressed: bool = false
var driving_enabled: bool = false
var stopping_requested: bool = false

func set_input(steer: float, gas: float, brake: bool) -> void:
	steering = clampf(steer, -1.0, 1.0)
	throttle = clampf(gas, 0.0, 1.0)
	brake_pressed = brake

func set_driving_enabled(value: bool) -> void:
	driving_enabled = value
	set_input(0.0, 0.0, false)

func stop_vehicle() -> void:
	stopping_requested = true
	set_input(0.0, 0.0, true)
	driving_enabled = true

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0
	if driving_enabled:
		var forward := -global_transform.basis.z
		var speed := velocity.dot(forward)
		if throttle > 0.0 and speed < max_speed:
			velocity += forward * acceleration * throttle * delta
		if brake_pressed:
			velocity -= forward * braking * clampf(speed / 4.0, -1.0, 1.0) * delta
		if stopping_requested and absf(velocity.dot(forward)) < 0.3:
			velocity.x = 0.0
			velocity.z = 0.0
			velocity.y = 0.0
			driving_enabled = false
			stopping_requested = false
			brake_pressed = false
		var speed_factor := clampf(absf(speed) / 4.0, 0.0, 1.0)
		rotate_y(deg_to_rad(steering * steering_degrees * speed_factor) * delta)
		var right := global_transform.basis.x
		velocity -= right * velocity.dot(right) * minf(1.0, lateral_grip * delta)
		var horizontal := Vector2(velocity.x, velocity.z)
		if horizontal.length() > max_speed:
			horizontal = horizontal.normalized() * max_speed
			velocity.x = horizontal.x
			velocity.z = horizontal.y
	move_and_slide()
