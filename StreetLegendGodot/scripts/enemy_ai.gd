extends "res://scripts/fighter.gd"
@export var pursuit_distance: float = 12.0
@export var preferred_distance: float = 1.25
@export var decision_interval: float = 0.18
var target: CharacterBody3D
var decision_timer: float = 0.0
func _ready() -> void:
	super._ready()
	is_player = false
func _physics_process(delta: float) -> void:
	attack_timer = maxf(0.0, attack_timer - delta)
	decision_timer -= delta
	if is_instance_valid(target) and decision_timer <= 0.0:
		decision_timer = decision_interval
		var offset: Vector3 = target.global_position - global_position
		offset.y = 0.0
		var distance := offset.length()
		if distance > preferred_distance and distance < pursuit_distance:
			var direction := offset.normalized()
			velocity.x = direction.x * move_speed * 0.72
			velocity.z = direction.z * move_speed * 0.72
			look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z))
		else:
			velocity.x = move_toward(velocity.x, 0.0, move_speed * 4.0 * delta)
			velocity.z = move_toward(velocity.z, 0.0, move_speed * 4.0 * delta)
			if distance <= attack_range:
				attack()
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0.0
	move_and_slide()
