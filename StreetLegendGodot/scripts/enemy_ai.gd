extends "res://scripts/fighter.gd"
class_name StreetLegendEnemy

@export var pursuit_distance: float = 12.0
@export var preferred_distance: float = 1.45
@export var decision_interval: float = 0.2
@export var attack_interval: float = 1.35
@export var attack_damage: float = 8.0
@export var attack_windup: float = 0.2
@export var circle_speed: float = 1.15
@export_range(0.0, 1.0) var guard_chance: float = 0.18
@export var guard_damage_multiplier: float = 0.35
var target: CharacterBody3D
var decision_timer: float = 0.0
var tactical_timer: float = 0.0
var circle_side: float = 1.0
var retreating: bool = false
var guard_cooldown: float = 0.0

func _ready() -> void:
	super._ready()
	is_player = false

func _physics_process(delta: float) -> void:
	attack_timer = maxf(0.0, attack_timer - delta)
	hit_stun_timer = maxf(0.0, hit_stun_timer - delta)
	decision_timer -= delta
	tactical_timer -= delta
	guard_cooldown = maxf(0.0, guard_cooldown - delta)
	if is_instance_valid(target) and target.is_inside_tree() and target.get("health") > 0.0 and hit_stun_timer <= 0.0:
		var offset := target.global_position - global_position
		offset.y = 0.0
		var distance := offset.length()
		if tactical_timer <= 0.0:
			tactical_timer = 2.4
			circle_side = -1.0 if randf() < 0.5 else 1.0
			retreating = randf() < 0.22
		if decision_timer <= 0.0:
			decision_timer = decision_interval
			var direction := Vector3.ZERO
			if distance > attack_range + 0.35:
				direction = offset.normalized()
			elif distance < 1.05 and retreating:
				direction = -offset.normalized()
			elif distance > 0.01:
				direction = Vector3.UP.cross(offset.normalized()) * circle_side * circle_speed
				direction += offset.normalized() * (0.25 if distance > attack_range else -0.12)
			if direction.length_squared() > 0.001:
				velocity.x = direction.normalized().x * move_speed * 0.72
				velocity.z = direction.normalized().z * move_speed * 0.72
			else:
				velocity.x = move_toward(velocity.x, 0.0, move_speed * 5.0 * delta)
				velocity.z = move_toward(velocity.z, 0.0, move_speed * 5.0 * delta)
			if distance <= attack_range and attack_timer <= 0.0 and not retreating:
				attack(false)
		if distance > 0.01:
			rotation.y = lerp_angle(rotation.y, atan2(-offset.x, -offset.z), 8.0 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, move_speed * 5.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, move_speed * 5.0 * delta)
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0
	move_and_slide()


func attack(heavy: bool = false) -> void:
	if attack_timer > 0.0 or hit_stun_timer > 0.0 or not is_instance_valid(target):
		return
	attack_timer = attack_interval * (1.5 if heavy else 1.0)
	attack_event.emit(&"opponent_started_attacking", 0.0, heavy)
	_resolve_enemy_attack(heavy)

func _resolve_enemy_attack(heavy: bool) -> void:
	await get_tree().create_timer(attack_windup).timeout
	if health <= 0.0 or hit_stun_timer > 0.0 or not is_instance_valid(target) or not target.is_inside_tree():
		return
	var origin := global_position + Vector3.UP
	var target_point := target.global_position + Vector3.UP
	var to_target := target_point - origin
	var distance := to_target.length()
	var flat := Vector3(to_target.x, 0.0, to_target.z)
	var forward := -global_transform.basis.z
	if distance > attack_range or distance < 0.01 or (flat.length_squared() > 0.001 and rad_to_deg(forward.angle_to(flat.normalized())) > attack_half_angle):
		attack_event.emit(&"opponent_attack_missed", 0.0, heavy)
		return
	var query := PhysicsRayQueryParameters3D.create(origin, target_point)
	query.exclude = [get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty() and hit.collider != target and not target.is_ancestor_of(hit.collider):
		attack_event.emit(&"opponent_attack_missed", 0.0, heavy)
		return
	if target.has_method("take_damage"):
		target.take_damage(attack_damage if not heavy else attack_damage * 2.0, forward, heavy)

func take_damage(amount: float, direction: Vector3 = Vector3.ZERO, heavy: bool = false) -> void:
	if health <= 0.0:
		return
	var incoming := maxf(0.0, amount)
	if guard_cooldown <= 0.0 and randf() < guard_chance:
		incoming *= clampf(guard_damage_multiplier, 0.0, 1.0)
		guard_cooldown = 1.8
		attack_event.emit(&"opponent_guarded", incoming, heavy)
	var applied := minf(health, incoming)
	health = maxf(0.0, health - applied)
	health_changed.emit(health)
	hit_stun_timer = 0.12 if incoming < amount else (0.75 if heavy else 0.28)
	attack_event.emit(&"opponent_damaged", applied, heavy)
	if direction.length_squared() > 0.001:
		velocity += direction.normalized() * (3.0 if heavy else 1.0)
	if health <= 0.0:
		knocked_out.emit()
		attack_event.emit(&"opponent_defeated", 0.0, heavy)
		set_physics_process(false)

func set_target(value: CharacterBody3D) -> void:
	target = value
	opponent = value
