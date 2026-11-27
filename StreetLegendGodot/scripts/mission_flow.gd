extends Node
class_name StreetLegendMissionFlow

signal phase_changed(new_phase: StringName)
signal mission_finished(victory: bool)

enum Phase { HOTEL_COMBAT, DRIVING_PURSUIT, ROADBLOCK, DISMOUNTING, ROADBLOCK_COMBAT, COMPLETE }
var phase: Phase = Phase.HOTEL_COMBAT
var player: Node3D
var hotel_enemy: Node
var vehicle: StreetLegendVehicleController
var roadblock_enemy: Node
var safe_exit_point: Node3D
var roadblock_point: Node3D
var chase_target: Node3D
var chase_distance_limit: float = 42.0
var _handoff_running := false
var hotel_required: int = 1
var roadblock_required: int = 1
var hotel_defeats: int = 0
var roadblock_defeats: int = 0

func begin_pursuit() -> void:
	if phase != Phase.HOTEL_COMBAT:
		return
	_set_phase(Phase.DRIVING_PURSUIT)
	if is_instance_valid(player):
		player.visible = false
		player.set_physics_process(false)
	if is_instance_valid(vehicle):
		vehicle.visible = true
		vehicle.set_driving_enabled(true)

func update_pursuit() -> void:
	if phase != Phase.DRIVING_PURSUIT or not is_instance_valid(vehicle) or not is_instance_valid(chase_target):
		return
	if vehicle.global_position.distance_to(chase_target.global_position) > chase_distance_limit:
		reach_roadblock()

func reach_roadblock() -> void:
	if phase != Phase.DRIVING_PURSUIT or _handoff_running:
		return
	_handoff_running = true
	_set_phase(Phase.DISMOUNTING)
	if is_instance_valid(vehicle):
		vehicle.stop_vehicle()
		vehicle.visible = true
	await get_tree().create_timer(1.6).timeout
	if is_instance_valid(player):
		if is_instance_valid(safe_exit_point):
			player.global_transform = safe_exit_point.global_transform
		player.visible = true
		player.set_physics_process(true)
	if is_instance_valid(roadblock_enemy):
		if is_instance_valid(roadblock_point):
			roadblock_enemy.global_transform = roadblock_point.global_transform
		roadblock_enemy.visible = true
		if roadblock_enemy.has_method("set_target"):
			roadblock_enemy.set_target(player)
		elif roadblock_enemy.has_method("set"):
			roadblock_enemy.set("target", player)
	if is_instance_valid(player) and player.has_method("set_opponent"):
		player.set_opponent(roadblock_enemy)
	elif is_instance_valid(player) and player.has_method("set"):
		player.set("opponent", roadblock_enemy)
	_set_phase(Phase.ROADBLOCK_COMBAT)
	_handoff_running = false

func notify_hotel_enemy_defeated() -> void:
	if phase == Phase.HOTEL_COMBAT:
		hotel_defeats += 1
		if hotel_defeats >= hotel_required:
			begin_pursuit()

func notify_roadblock_enemy_defeated() -> void:
	if phase == Phase.ROADBLOCK_COMBAT:
		roadblock_defeats += 1
		if roadblock_defeats >= roadblock_required:
			_set_phase(Phase.COMPLETE)
			mission_finished.emit(true)

func notify_player_defeated() -> void:
	if phase == Phase.ROADBLOCK_COMBAT:
		_set_phase(Phase.COMPLETE)
		mission_finished.emit(false)

func _set_phase(next_phase: Phase) -> void:
	phase = next_phase
	phase_changed.emit(Phase.keys()[phase].to_snake_case())
