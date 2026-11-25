extends CharacterBody3D
class_name StreetLegendFighter

signal health_changed(value: float)
signal knocked_out
signal attack_event(event_type: StringName, amount: float, heavy: bool)

@export var move_speed: float = 4.2
@export var gravity: float = 20.0
@export var max_health: float = 100.0
@export var attack_range: float = 1.65
@export_range(0.0, 90.0) var attack_half_angle: float = 55.0
@export var light_damage: float = 12.0
@export var heavy_damage: float = 28.0
@export var attack_cooldown: float = 0.55
@export var light_windup: float = 0.16
@export var heavy_windup: float = 0.28
@export var opponent: CharacterBody3D
var health: float = 100.0
var is_player: bool = false
var display_name: String = "Fighter"
var attack_timer: float = 0.0
var hit_stun_timer: float = 0.0
var mobile_move_input := Vector2.ZERO
var _moving := false

func _ready() -> void:
	health = max_health
	add_to_group("fighters")
	health_changed.emit(health)

func _physics_process(delta: float) -> void:
	attack_timer = maxf(0.0, attack_timer - delta)
	hit_stun_timer = maxf(0.0, hit_stun_timer - delta)
	if is_player:
		_update_player(delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, move_speed * 5.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, move_speed * 5.0 * delta)
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0
	move_and_slide()

func _update_player(delta: float) -> void:
	var keyboard := Vector2(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"), Input.get_action_strength("move_back") - Input.get_action_strength("move_forward"))
	var move_input := keyboard if keyboard.length_squared() > 0.01 else mobile_move_input
	move_input = move_input.limit_length(1.0)
	var moving := move_input.length_squared() > 0.01 and hit_stun_timer <= 0.0 and health > 0.0
	if moving:
		velocity.x = move_input.x * move_speed
		velocity.z = move_input.y * move_speed
		if not is_instance_valid(opponent):
			rotation.y = lerp_angle(rotation.y, atan2(-move_input.x, -move_input.y), 12.0 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, move_speed * 7.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, move_speed * 7.0 * delta)
	if moving != _moving:
		_moving = moving
		attack_event.emit(&"player_started_moving" if moving else &"player_stopped_moving", 0.0, false)
	if is_instance_valid(opponent) and opponent.is_inside_tree():
		var face := opponent.global_position - global_position
		face.y = 0.0
		if face.length_squared() > 0.01:
			rotation.y = lerp_angle(rotation.y, atan2(-face.x, -face.z), 8.0 * delta)
	if Input.is_action_just_pressed("attack"):
		attack(false)
	if Input.is_action_just_pressed("heavy_attack"):
		attack(true)

func set_mobile_move_input(value: Vector2) -> void:
	mobile_move_input = value.limit_length(1.0)

func set_opponent(value: CharacterBody3D) -> void:
	opponent = value

func attack(heavy: bool = false) -> void:
	if attack_timer > 0.0 or hit_stun_timer > 0.0 or health <= 0.0:
		return
	attack_timer = attack_cooldown * (1.5 if heavy else 1.0)
	attack_event.emit(&"player_attack_started", 0.0, heavy)
	_resolve_attack(heavy)

func _resolve_attack(heavy: bool) -> void:
	await get_tree().create_timer(heavy_windup if heavy else light_windup).timeout
	if health <= 0.0 or hit_stun_timer > 0.0 or not is_instance_valid(opponent) or not opponent.is_inside_tree():
		return
	var target_point := opponent.global_position + Vector3.UP
	var to_target := target_point - (global_position + Vector3.UP)
	var distance := to_target.length()
	var flat := Vector3(to_target.x, 0.0, to_target.z)
	var forward := -global_transform.basis.z
	if distance > attack_range or distance < 0.01 or (flat.length_squared() > 0.001 and rad_to_deg(forward.angle_to(flat.normalized())) > attack_half_angle):
		attack_event.emit(&"player_attack_missed", 0.0, heavy)
		return
	var space := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(global_position + Vector3.UP, target_point)
	query.exclude = [get_rid()]
	var hit := space.intersect_ray(query)
	if not hit.is_empty() and hit.collider != opponent and not opponent.is_ancestor_of(hit.collider):
		attack_event.emit(&"player_attack_missed", 0.0, heavy)
		return
	if opponent.has_method("take_damage"):
		var damage := heavy_damage if heavy else light_damage
		var before := float(opponent.get("health"))
		opponent.take_damage(damage, forward, heavy)
		var applied := maxf(0.0, before - float(opponent.get("health")))
		if applied > 0.0:
			attack_event.emit(&"player_hit_confirmed", applied, heavy)
		else:
			attack_event.emit(&"player_attack_missed", 0.0, heavy)

func take_damage(amount: float, direction: Vector3 = Vector3.ZERO, heavy: bool = false) -> void:
	if health <= 0.0 or hit_stun_timer > 0.0:
		return
	var applied := minf(health, maxf(0.0, amount))
	health = maxf(0.0, health - applied)
	hit_stun_timer = 0.65 if heavy else 0.25
	health_changed.emit(health)
	attack_event.emit(&"player_damaged", applied, heavy)
	if direction.length_squared() > 0.001:
		velocity += direction.normalized() * (2.2 if heavy else 0.8)
	if health <= 0.0:
		knocked_out.emit()
		attack_event.emit(&"player_knocked_out", 0.0, heavy)
		set_physics_process(false)

func reset_vertical_motion() -> void:
	velocity.y = 0.0
	hit_stun_timer = 0.0
