extends CharacterBody3D
class_name StreetLegendFighter
signal health_changed(value: float)
signal knocked_out
@export var move_speed: float = 4.6
@export var max_health: float = 100.0
@export var attack_damage: float = 18.0
@export var attack_range: float = 1.65
@export var attack_cooldown: float = 0.62
var health: float = 100.0
var is_player: bool = false
var display_name: String = "Fighter"
var attack_timer: float = 0.0
var opponent: CharacterBody3D
func _ready() -> void:
	health = max_health
	add_to_group("fighters")
func _physics_process(delta: float) -> void:
	attack_timer = maxf(0.0, attack_timer - delta)
	if is_player:
		_player_movement()
	else:
		velocity.x = move_toward(velocity.x, 0.0, move_speed * 5.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, move_speed * 5.0 * delta)
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0.0
	move_and_slide()
func _player_movement() -> void:
	var input_vector := Vector2(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"), Input.get_action_strength("move_back") - Input.get_action_strength("move_forward"))
	if input_vector.length() > 1.0:
		input_vector = input_vector.normalized()
	velocity.x = input_vector.x * move_speed
	velocity.z = input_vector.y * move_speed
	if input_vector.length_squared() > 0.01:
		rotation.y = lerp_angle(rotation.y, atan2(-input_vector.x, -input_vector.y), 0.22)
	if Input.is_action_just_pressed("attack"):
		attack()
func attack() -> void:
	if attack_timer > 0.0:
		return
	attack_timer = attack_cooldown
	var target := opponent
	if target == null:
		for candidate in get_tree().get_nodes_in_group("fighters"):
			if candidate != self and candidate is CharacterBody3D:
				target = candidate
				break
	if target and is_instance_valid(target) and global_position.distance_to(target.global_position) <= attack_range:
		if target.has_method("take_damage"):
			target.take_damage(attack_damage)
func take_damage(amount: float) -> void:
	health = maxf(0.0, health - amount)
	health_changed.emit(health)
	if health <= 0.0:
		knocked_out.emit()
		set_physics_process(false)
