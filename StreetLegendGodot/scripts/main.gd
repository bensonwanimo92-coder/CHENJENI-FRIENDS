extends Node3D

const FighterScript = preload("res://scripts/fighter.gd")
const EnemyScript = preload("res://scripts/enemy_ai.gd")
const MobileControlsScript = preload("res://scripts/mobile_controls.gd")
const VehicleScript = preload("res://scripts/vehicle_controller.gd")
const ChaseScript = preload("res://scripts/chase_target.gd")
const CameraScript = preload("res://scripts/third_person_camera.gd")
const MissionScript = preload("res://scripts/mission_flow.gd")
const CommentatorScript = preload("res://scripts/commentator.gd")
const AnimationDriverScript = preload("res://scripts/animation_driver.gd")
const FallRecoveryScript = preload("res://scripts/fall_recovery.gd")
const MatchManagerScript = preload("res://scripts/match_manager.gd")

var player: StreetLegendFighter
var hotel_enemy: StreetLegendFighter
var roadblock_enemy: StreetLegendFighter
var vehicle: StreetLegendVehicleController
var chase_target: StreetLegendChaseTarget
var roadblock_marker: Node3D
var mission: StreetLegendMissionFlow
var controls: StreetLegendMobileControls
var camera_rig: StreetLegendThirdPersonCamera
var status_label: Label
var player_health_label: Label
var enemy_health_label: Label
var commentator: StreetLegendCommentator
var match_manager: Node
var hotel_wave: Array[StreetLegendFighter] = []
var roadblock_wave: Array[StreetLegendFighter] = []

func _ready() -> void:
	_build_world()
	_build_hud()
	player = _spawn_fighter("WANIMO", Vector3(-2.0, 0.0, 0.0), Color(0.08, 0.42, 0.82), true)
	hotel_enemy = _spawn_fighter("HOTEL ENFORCER", Vector3(2.0, 0.0, 0.0), Color(0.72, 0.12, 0.10), false)
	hotel_enemy.set_target(player)
	hotel_wave.append(hotel_enemy)
	player.set("opponent", hotel_enemy)
	player.health_changed.connect(_on_player_health_changed)
	hotel_enemy.health_changed.connect(_on_hotel_enemy_health_changed)
	roadblock_enemy = _spawn_fighter("ROADBLOCK ENFORCER", Vector3(2.0, 0.0, -60.0), Color(0.68, 0.16, 0.12), false)
	roadblock_enemy.visible = false
	roadblock_enemy.set_physics_process(false)
	roadblock_wave.append(roadblock_enemy)
	roadblock_enemy.health_changed.connect(_on_roadblock_health_changed)
	vehicle = _spawn_vehicle()
	chase_target = _spawn_chase_target()
	roadblock_marker = Node3D.new()
	roadblock_marker.position = Vector3(0.0, 0.0, -46.0)
	add_child(roadblock_marker)
	mission = MissionScript.new()
	add_child(mission)
	mission.set("player", player)
	mission.set("hotel_enemy", hotel_enemy)
	mission.set("vehicle", vehicle)
	mission.set("roadblock_enemy", roadblock_enemy)
	mission.set("safe_exit_point", _make_marker(Vector3(-2.0, 0.0, -58.0), "WanimoDismountPoint"))
	mission.set("roadblock_point", _make_marker(Vector3(2.0, 0.0, -60.0), "RoadblockFighterPoint"))
	mission.set("chase_target", chase_target)
	hotel_enemy.knocked_out.connect(mission.notify_hotel_enemy_defeated)
	hotel_enemy.knocked_out.connect(_refresh_combat_target.bind(true))
	player.attack_event.connect(_on_combat_event)
	hotel_enemy.attack_event.connect(_on_combat_event)
	roadblock_enemy.attack_event.connect(_on_combat_event)
	commentator = CommentatorScript.new()
	add_child(commentator)
	roadblock_enemy.knocked_out.connect(mission.notify_roadblock_enemy_defeated)
	roadblock_enemy.knocked_out.connect(_refresh_combat_target.bind(false))
	_spawn_combat_wave("HOTEL BACKUP", [Vector3(-5.0, 0.0, -2.0), Vector3(5.0, 0.0, -3.0)], Color(0.55, 0.12, 0.16), hotel_wave, mission.notify_hotel_enemy_defeated)
	_spawn_combat_wave("ROADBLOCK GUARD", [Vector3(-4.0, 0.0, -61.0), Vector3(5.0, 0.0, -63.0)], Color(0.62, 0.18, 0.12), roadblock_wave, mission.notify_roadblock_enemy_defeated)
	mission.set("hotel_required", hotel_wave.size())
	mission.set("roadblock_required", roadblock_wave.size())
	player.knocked_out.connect(mission.notify_player_defeated)
	mission.phase_changed.connect(_on_mission_phase_changed)
	mission.mission_finished.connect(_on_mission_finished)
	match_manager = MatchManagerScript.new()
	match_manager.name = "MatchManager"
	add_child(match_manager)
	match_manager.call("configure", mission)
	controls = MobileControlsScript.new()
	controls.pause_requested.connect(match_manager.call.bind("toggle_pause"))
	controls.set("fighter", player)
	controls.set("vehicle", vehicle)
	add_child(controls)
	controls.call("set_driving_mode", false)
	camera_rig.set("target", player)
	_update_status("HOTEL LOBBY  •  DEFEAT THE ENFORCER")

func _process(_delta: float) -> void:
	if mission != null and mission.get("phase") == 1 and is_instance_valid(vehicle):
		if vehicle.global_position.distance_to(roadblock_marker.global_position) <= 4.5:
			mission.reach_roadblock()

func _build_world() -> void:
	var environment := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.035, 0.055, 0.085)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.62, 0.70, 0.82)
	env.ambient_light_energy = 0.7
	environment.environment = env
	add_child(environment)
	var floor_body := StaticBody3D.new()
	floor_body.name = "LevelFloor"
	var floor_mesh := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(40.0, 180.0)
	floor_mesh.mesh = plane
	var floor_material := StandardMaterial3D.new()
	floor_material.albedo_color = Color(0.12, 0.15, 0.18)
	floor_material.roughness = 0.92
	floor_mesh.material_override = floor_material
	floor_body.add_child(floor_mesh)
	var floor_collision := CollisionShape3D.new()
	var floor_shape := BoxShape3D.new()
	floor_shape.size = Vector3(40.0, 0.2, 180.0)
	floor_collision.shape = floor_shape
	floor_collision.position = Vector3(0.0, -0.1, 0.0)
	floor_body.position.z = -35.0
	floor_body.add_child(floor_collision)
	add_child(floor_body)
	_build_lobby_set()
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48.0, -28.0, 0.0)
	sun.light_energy = 1.35
	add_child(sun)
	camera_rig = CameraScript.new()
	camera_rig.name = "ThirdPersonCamera"
	camera_rig.position = Vector3(0.0, 7.5, 10.5)
	camera_rig.current = true
	add_child(camera_rig)
	# A visible roadblock marks the end of the chase; the player must dismount and fight.
	var barrier := MeshInstance3D.new()
	barrier.name = "RoadblockBarrier"
	var barrier_mesh := BoxMesh.new()
	barrier_mesh.size = Vector3(12.0, 1.5, 0.8)
	barrier.mesh = barrier_mesh
	barrier.position = Vector3(0.0, 0.8, -62.0)
	var barrier_mat := StandardMaterial3D.new()
	barrier_mat.albedo_color = Color(0.82, 0.48, 0.08)
	barrier.material_override = barrier_mat
	add_child(barrier)



func _refresh_combat_target(is_hotel: bool) -> void:
	if not is_instance_valid(player):
		return
	var wave: Array[StreetLegendFighter] = hotel_wave if is_hotel else roadblock_wave
	for fighter in wave:
		if is_instance_valid(fighter) and fighter.health > 0.0 and fighter.visible:
			player.set_opponent(fighter)
			return

func _spawn_combat_wave(label: String, positions: Array[Vector3], tint: Color, wave: Array[StreetLegendFighter], defeated_callback: Callable) -> void:
	for i in positions.size():
		var enemy := _spawn_fighter("%s %d" % [label, i + 1], positions[i], tint, false)
		enemy.set_target(player)
		enemy.visible = false if wave == roadblock_wave else true
		enemy.set_physics_process(wave != roadblock_wave)
		enemy.health_changed.connect(_on_hotel_enemy_health_changed if wave == hotel_wave else _on_roadblock_health_changed)
		enemy.knocked_out.connect(defeated_callback)
		enemy.knocked_out.connect(_refresh_combat_target.bind(wave == hotel_wave))
		enemy.attack_event.connect(_on_combat_event)
		wave.append(enemy)

func _spawn_fighter(label: String, spawn: Vector3, tint: Color, is_player: bool) -> StreetLegendFighter:
	var body := CharacterBody3D.new()
	body.name = label.replace(" ", "")
	body.position = spawn
	body.set_script(FighterScript if is_player else EnemyScript)
	body.set("is_player", is_player)
	body.set("display_name", label)
	_build_fighter_visual(body, tint, is_player)
	var animation_driver := Node.new()
	animation_driver.name = "AnimationDriver"
	animation_driver.set_script(AnimationDriverScript)
	body.add_child(animation_driver)
	var fall_recovery := Node.new()
	fall_recovery.name = "FallRecovery"
	fall_recovery.set_script(FallRecoveryScript)
	body.add_child(fall_recovery)
	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.42
	shape.height = 1.8
	collision.shape = shape
	collision.position.y = 0.9
	body.add_child(collision)
	add_child(body)
	return body as StreetLegendFighter

func _spawn_vehicle() -> StreetLegendVehicleController:
	var car := CharacterBody3D.new()
	car.name = "WanimoCar"
	car.set_script(VehicleScript)
	car.position = Vector3(0.0, 0.0, -1.0)
	_add_vehicle_visuals(car, Color(0.06, 0.12, 0.18), false)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.9, 1.05, 3.7)
	collision.shape = shape
	collision.position.y = 0.65
	car.add_child(collision)
	add_child(car)
	car.visible = false
	return car as StreetLegendVehicleController

func _add_vehicle_visuals(root: Node3D, paint: Color, suv: bool) -> void:
	var body_mat := StandardMaterial3D.new()
	body_mat.albedo_color = paint
	body_mat.metallic = 0.5
	body_mat.roughness = 0.32
	var glass_mat := StandardMaterial3D.new()
	glass_mat.albedo_color = Color(0.12, 0.22, 0.29)
	glass_mat.metallic = 0.25
	glass_mat.roughness = 0.2
	var tire_mat := StandardMaterial3D.new()
	tire_mat.albedo_color = Color(0.025, 0.025, 0.03)
	tire_mat.roughness = 0.9
	var body := MeshInstance3D.new()
	var body_mesh := BoxMesh.new()
	body_mesh.size = Vector3(1.9, 0.65, 3.7 if not suv else 4.2)
	body.mesh = body_mesh
	body.position.y = 0.55
	body.material_override = body_mat
	root.add_child(body)
	var cabin := MeshInstance3D.new()
	var cabin_mesh := BoxMesh.new()
	cabin_mesh.size = Vector3(1.55, 0.72 if not suv else 0.9, 1.9 if not suv else 2.15)
	cabin.mesh = cabin_mesh
	cabin.position = Vector3(0.0, 1.15 if not suv else 1.25, -0.15)
	cabin.material_override = glass_mat
	root.add_child(cabin)
	for x in [-0.98, 0.98]:
		for z in [-1.25, 1.25]:
			var wheel := MeshInstance3D.new()
			var wheel_mesh := CylinderMesh.new()
			wheel_mesh.top_radius = 0.38 if not suv else 0.42
			wheel_mesh.bottom_radius = wheel_mesh.top_radius
			wheel_mesh.height = 0.24
			wheel.mesh = wheel_mesh
			wheel.rotation.z = PI / 2.0
			wheel.position = Vector3(x, 0.38, z)
			wheel.material_override = tire_mat
			root.add_child(wheel)
	for x in [-0.65, 0.65]:
		var lamp := MeshInstance3D.new()
		var lm := BoxMesh.new()
		lm.size = Vector3(0.32, 0.16, 0.08)
		lamp.mesh = lm
		lamp.position = Vector3(x, 0.62, -1.9 if not suv else -2.1)
		lamp.material_override = StandardMaterial3D.new()
		lamp.material_override.albedo_color = Color(0.85, 0.8, 0.55)
		root.add_child(lamp)
	# Bodywork details: grille, bumpers, tail lamps, mirrors and trim stripes.
	var chrome := _mat(Color(0.42, 0.46, 0.5), 0.25)
	var red_lamp := _mat(Color(0.75, 0.06, 0.04), 0.25)
	var bumper := _mat(Color(0.035, 0.04, 0.045), 0.45)
	_add_box("Front grille", Vector3(0.72, 0.28, 0.12), Vector3(0, 0.52, -2.0 if suv else -1.78), chrome)
	_add_box("Front bumper", Vector3(1.85, 0.22, 0.18), Vector3(0, 0.25, -2.12 if suv else -1.95), bumper)
	_add_box("Rear bumper", Vector3(1.85, 0.22, 0.18), Vector3(0, 0.25, 2.0), bumper)
	for x in [-0.82, 0.82]:
		_add_box("Side mirror", Vector3(0.18, 0.16, 0.22), Vector3(x, 1.12, -1.05), body_mat)
		_add_box("Rear tail lamp", Vector3(0.28, 0.28, 0.09), Vector3(x, 0.72, 2.12), red_lamp)
		_add_box("Door side trim", Vector3(0.05, 0.28, 1.4), Vector3(x, 0.65, 0.0), chrome)
	_add_box("Roof rack", Vector3(1.3, 0.08, 1.55), Vector3(0, 1.72 if suv else 1.52, 0.0), bumper)

func _spawn_chase_target() -> StreetLegendChaseTarget:
	var rover := Node3D.new()
	rover.name = "EscapingRangeRover"
	rover.set_script(ChaseScript)
	rover.position = Vector3(0.0, 0.0, -23.0)
	_add_vehicle_visuals(rover, Color(0.12, 0.13, 0.15), true)
	var waypoint := Node3D.new()
	waypoint.position = Vector3(0.0, 0.0, -110.0)
	add_child(waypoint)
	rover.set("route", [waypoint])
	rover.set("player_vehicle", vehicle)
	add_child(rover)
	return rover as StreetLegendChaseTarget

func _make_marker(position: Vector3, marker_name: String) -> Node3D:
	var marker := Node3D.new()
	marker.name = marker_name
	marker.position = position
	add_child(marker)
	return marker

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	var panel := PanelContainer.new()
	panel.position = Vector2(24.0, 20.0)
	panel.custom_minimum_size = Vector2(430.0, 94.0)
	layer.add_child(panel)
	var column := VBoxContainer.new()
	panel.add_child(column)
	var title := Label.new()
	title.text = "STREET LEGEND  /  LEVEL 01"
	title.add_theme_font_size_override("font_size", 20)
	column.add_child(title)
	status_label = Label.new()
	status_label.text = "Preparing encounter..."
	column.add_child(status_label)
	player_health_label = Label.new()
	player_health_label.text = "WANIMO 100%"
	column.add_child(player_health_label)
	enemy_health_label = Label.new()
	enemy_health_label.text = "ENFORCER 100%"
	column.add_child(enemy_health_label)
	var help := Label.new()
	help.text = "Touch joystick + strike buttons  •  Landscape mode"
	column.add_child(help)
	add_child(layer)

func _on_mission_phase_changed(new_phase: StringName) -> void:
	if new_phase == &"driving_pursuit":
		if is_instance_valid(enemy_health_label):
			enemy_health_label.text = "PURSUIT  •  ESCAPING SUV"
		controls.call("set_driving_mode", true)
		camera_rig.set("target", vehicle)
		_update_status("PURSUIT  •  THE RANGE ROVER IS PULLING AWAY")
	elif new_phase == &"roadblock_combat":
		if is_instance_valid(enemy_health_label):
			enemy_health_label.text = "ROADBLOCK ENFORCER  •  %d%%" % roundi(roadblock_enemy.health)
		controls.call("set_driving_mode", false)
		camera_rig.set("target", player)
		for enemy in roadblock_wave:
			enemy.visible = true
			enemy.set_physics_process(true)
			if enemy.has_method("set_target"):
				enemy.set_target(player)
		_update_status("ROADBLOCK  •  GET OUT AND FIGHT")
	elif new_phase == &"dismounting":
		_update_status("ROADBLOCK AHEAD  •  VEHICLE STOPPING")
		commentator.announce(&"roadblock_reached")

func _on_mission_finished(victory: bool) -> void:
	_update_status("LEVEL 01 COMPLETE  •  ROADBLOCK CLEARED" if victory else "WANIMO DOWN  •  RETRY REQUIRED")
	commentator.announce(&"mission_complete", "Level one complete. The roadblock is cleared." if victory else "Wanimo is down. The mission has failed.")

func _on_combat_event(event_type: StringName, _amount: float, _heavy: bool) -> void:
	commentator.announce(event_type)

func _on_player_health_changed(value: float) -> void:
	if is_instance_valid(player_health_label):
		player_health_label.text = "WANIMO  •  %d%%" % roundi(value)

func _on_hotel_enemy_health_changed(value: float) -> void:
	if mission != null and mission.phase == MissionScript.Phase.HOTEL_COMBAT and is_instance_valid(enemy_health_label):
		enemy_health_label.text = "HOTEL ENFORCER  •  %d%%" % roundi(value)

func _on_roadblock_health_changed(value: float) -> void:
	if mission != null and mission.phase >= MissionScript.Phase.ROADBLOCK and is_instance_valid(enemy_health_label):
		enemy_health_label.text = "ROADBLOCK ENFORCER  •  %d%%" % roundi(value))

func _update_status(message: String) -> void:
	if is_instance_valid(status_label):
		status_label.text = message

func _build_lobby_set() -> void:
	# Expanded three-dimensional hotel lobby architecture.
	var stone := _mat(Color(0.20, 0.23, 0.27), 0.9)
	var polished := _mat(Color(0.36, 0.39, 0.43), 0.3)
	var gold := _mat(Color(0.65, 0.48, 0.22), 0.4)
	var glass := _mat(Color(0.10, 0.22, 0.30), 0.2)
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var tile := _mat(Color(0.31, 0.34, 0.38), 0.2)
	_add_box("Lobby back wall", Vector3(22, 6, 0.6), Vector3(0, 3, -10), stone)
	_add_box("Lobby left wall", Vector3(0.6, 6, 24), Vector3(-11, 3, 1), stone)
	_add_box("Lobby right wall", Vector3(0.6, 6, 24), Vector3(11, 3, 1), stone)
	_add_box("Ceiling", Vector3(22, 0.4, 24), Vector3(0, 6, 1), stone)
	for x in range(-9, 10, 3):
		_add_box("Floor tile strip", Vector3(2.8, 0.04, 24), Vector3(x, 0.015, 1), tile)
	for x in [-9,-6,-3,3,6,9]:
		_add_box("Lobby pillar", Vector3(0.7, 5.6, 0.7), Vector3(x, 2.8, 0), gold)
	for x in [-7.5,-4.5,-1.5,1.5,4.5,7.5]:
		_add_box("Window panel", Vector3(2.6, 3.7, 0.12), Vector3(x, 2.5, -9.62), glass)
		_add_box("Window mullion", Vector3(0.12, 4.1, 0.18), Vector3(x, 2.5, -9.5), gold)
	_add_box("Reception desk", Vector3(4.6, 1.3, 1.2), Vector3(-6, 0.65, -5), polished)
	_add_box("Reception fascia", Vector3(4.4, 0.18, 1.25), Vector3(-6, 1.25, -5), gold)
	for x in [-7.5,7.5]:
		_add_box("Lounge sofa seat", Vector3(3,0.6,1), Vector3(x,0.35,2), polished)
		_add_box("Lounge sofa back", Vector3(3,1.0,0.3), Vector3(x,0.95,1.55), stone)
		_add_box("Coffee table", Vector3(1.8,0.45,1.1), Vector3(x,0.25,4), gold)
	# Broad overhead light panels, luminous material.
	var lightmat := _mat(Color(0.85,0.78,0.63), 0.2)
	for x in [-6,-2,2,6]:
		_add_box("Ceiling light panel", Vector3(2.4,0.08,4), Vector3(x,5.78,1), lightmat)
	# corridor framing toward the exit/chase sequence
	for z in [-14,-20,-26,-32,-38]:
		for x in [-6,6]:
			_add_box("Corridor support", Vector3(0.6,4,0.6), Vector3(x,2.0,z), stone)
		_add_box("Corridor crossbeam", Vector3(12,0.35,0.5), Vector3(0,4,z), gold)

	# Environment dressing: hotel trim, lighting, foliage, entrance and roadway details.
	var trim := _mat(Color(0.48, 0.43, 0.34), 0.38)
	var dark := _mat(Color(0.055, 0.075, 0.09), 0.3)
	var foliage := _mat(Color(0.12, 0.28, 0.16), 0.85)
	var leaf_light := _mat(Color(0.22, 0.39, 0.21), 0.8)
	var signage := _mat(Color(0.04, 0.14, 0.23), 0.25)
	_add_box("Lobby cornice", Vector3(22, 0.35, 0.8), Vector3(0, 5.55, -10.2), trim)
	_add_box("Lobby baseboard", Vector3(21.8, 0.22, 0.25), Vector3(0, 0.18, -9.55), dark)
	_add_box("Entrance frame left", Vector3(0.45, 4.2, 0.65), Vector3(-3.8, 2.1, -10.4), trim)
	_add_box("Entrance frame right", Vector3(0.45, 4.2, 0.65), Vector3(3.8, 2.1, -10.4), trim)
	_add_box("Entrance header", Vector3(8.0, 0.45, 0.65), Vector3(0, 4.25, -10.4), trim)
	_add_box("Lobby sign backing", Vector3(5.8, 0.85, 0.18), Vector3(0, 4.85, -9.25), signage)
	_add_box("Lobby sign accent", Vector3(5.4, 0.06, 0.2), Vector3(0, 4.42, -9.18), gold)
	for x in [-4.0, 4.0]:
		_add_box("Floor brass inlay", Vector3(0.12, 0.025, 18), Vector3(x, 0.04, -3.0), trim)
	var glow := StandardMaterial3D.new()
	glow.albedo_color = Color(0.96, 0.83, 0.62)
	glow.emission_enabled = true
	glow.emission = Color(0.9, 0.65, 0.35)
	glow.emission_energy_multiplier = 1.3
	for x in [-8, -4, 0, 4, 8]:
		for z in [-5, 1, 5]:
			_add_box("Downlight", Vector3(0.9, 0.06, 0.9), Vector3(x, 5.72, z), glow)
	for x in [-9.0, 9.0, -4.5, 4.5]:
		_add_box("Lobby planter", Vector3(1.1, 0.65, 1.1), Vector3(x, 0.33, 5.5), dark)
		for offset in [-0.35, 0.0, 0.35]:
			_add_sphere("Plant leaf cluster", Vector3(x + offset, 1.1 + abs(offset), 5.5 + offset), 0.34, foliage)
			_add_sphere("Plant highlight", Vector3(x - offset, 1.35, 5.5 - offset), 0.26, leaf_light)
	_add_box("Reception countertop", Vector3(4.8, 0.12, 1.35), Vector3(-6, 1.38, -5), trim)
	_add_box("Reception monitor", Vector3(0.8, 0.5, 0.12), Vector3(-6, 1.75, -4.7), dark)
	for x in [-8.3, -6.8, 6.8, 8.3]:
		_add_box("Seat cushion accent", Vector3(0.55, 0.45, 0.85), Vector3(x, 0.68, 2), gold)
	for z in [-16, -22, -28, -34, -40]:
		_add_box("Corridor window", Vector3(2.8, 2.6, 0.08), Vector3(-8.0, 2.0, z), glass)
		_add_box("Corridor window frame", Vector3(0.12, 2.9, 0.15), Vector3(-8.0, 2.0, z), trim)
	_add_box("Road curb left", Vector3(0.5, 0.3, 64), Vector3(-13.5, 0.15, -54), dark)
	_add_box("Road curb right", Vector3(0.5, 0.3, 64), Vector3(13.5, 0.15, -54), dark)
	var lane_mat := _mat(Color(0.75, 0.72, 0.62), 0.8)
	for z in range(-44, -112, -8):
		_add_box("Road lane marker", Vector3(0.22, 0.025, 3.0), Vector3(0, 0.03, z), lane_mat)

func _add_sphere(label: String, location: Vector3, radius: float, material: Material) -> void:
	var instance := MeshInstance3D.new()
	instance.name = label
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	instance.mesh = mesh
	instance.position = location
	instance.material_override = material
	add_child(instance)

func _mat(color: Color, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	return material

func _add_box(label: String, size: Vector3, location: Vector3, material: Material) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = label
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.position = location
	mesh_instance.material_override = material
	add_child(mesh_instance)

func _build_fighter_visual(root: Node3D, tint: Color, is_player: bool) -> void:
	# Keep a stable visual pivot so the animation driver can pose the complete silhouette.
	var visual := Node3D.new()
	visual.name = "PlaceholderBody"
	root.add_child(visual)
	var skin := Color(0.48, 0.31, 0.22)
	var outfit := tint.darkened(0.22)
	var head := MeshInstance3D.new()
	head.name = "Head"
	var headmesh := SphereMesh.new()
	headmesh.radius = 0.19
	headmesh.height = 0.38
	head.mesh = headmesh
	head.position = Vector3(0, 1.67, 0)
	var skinmat := StandardMaterial3D.new()
	skinmat.albedo_color = skin
	head.material_override = skinmat
	visual.add_child(head)
	var torso := MeshInstance3D.new()
	torso.name = "Torso"
	var chest := BoxMesh.new()
	chest.size = Vector3(0.66, 0.68, 0.34)
	torso.mesh = chest
	torso.position = Vector3(0, 1.18, 0)
	var clothmat := StandardMaterial3D.new()
	clothmat.albedo_color = tint
	clothmat.roughness = 0.82
	torso.material_override = clothmat
	visual.add_child(torso)
	var hips := MeshInstance3D.new()
	var hipmesh := BoxMesh.new()
	hipmesh.size = Vector3(0.48, 0.28, 0.32)
	hips.mesh = hipmesh
	hips.position.y = 0.78
	var pantsmat := StandardMaterial3D.new()
	pantsmat.albedo_color = outfit
	hips.material_override = pantsmat
	visual.add_child(hips)
	for side in [-1.0, 1.0]:
		var arm := MeshInstance3D.new()
		var armmesh := CapsuleMesh.new()
		armmesh.radius = 0.13
		armmesh.height = 0.62
		arm.mesh = armmesh
		arm.position = Vector3(side * 0.46, 1.12, 0.02)
		arm.rotation.z = side * -0.22
		arm.material_override = clothmat
		visual.add_child(arm)
		var hand := MeshInstance3D.new()
		var handmesh := SphereMesh.new()
		handmesh.radius = 0.13
		handmesh.height = 0.24
		hand.mesh = handmesh
		hand.position = Vector3(side * 0.52, 0.79, -0.03)
		hand.material_override = skinmat
		visual.add_child(hand)
		var leg := MeshInstance3D.new()
		var legmesh := CapsuleMesh.new()
		legmesh.radius = 0.16
		legmesh.height = 0.72
		leg.mesh = legmesh
		leg.position = Vector3(side * 0.18, 0.42, 0.0)
		leg.material_override = pantsmat
		visual.add_child(leg)
		var boot := MeshInstance3D.new()
		var bootmesh := BoxMesh.new()
		bootmesh.size = Vector3(0.28, 0.14, 0.38)
		boot.mesh = bootmesh
		boot.position = Vector3(side * 0.18, 0.08, -0.07)
		var bootmat := StandardMaterial3D.new()
		bootmat.albedo_color = Color(0.06, 0.055, 0.045)
		boot.material_override = bootmat
		visual.add_child(boot)
	var shoulder := MeshInstance3D.new()
	var shoulder_mesh := BoxMesh.new()
	shoulder_mesh.size = Vector3(0.82, 0.16, 0.38)
	shoulder.mesh = shoulder_mesh
	shoulder.position.y = 1.43
	shoulder.material_override = clothmat
	visual.add_child(shoulder)
	# Add visible facial and equipment detail to the temporary articulated fighters.
	var face_detail := _mat(Color(0.09, 0.065, 0.05), 0.55)
	var eye_mat := _mat(Color(0.92, 0.86, 0.72), 0.3)
	var accent_mat := _mat(Color(0.82, 0.62, 0.18) if is_player else Color(0.68, 0.12, 0.08), 0.4)
	# Eyes, brows and ears are attached to the visual pivot for pose continuity.
	for side in [-1.0, 1.0]:
		_add_visual_sphere(visual, "Eye", Vector3(side * 0.075, 1.69, -0.165), Vector3(0.045, 0.035, 0.025), eye_mat)
		_add_visual_box(visual, "Brow", Vector3(0.10, 0.035, 0.03), Vector3(side * 0.075, 1.75, -0.17), face_detail)
		_add_visual_sphere(visual, "Ear", Vector3(side * 0.19, 1.65, 0.0), Vector3(0.055, 0.08, 0.06), skinmat)
	# Waist belt and contrasting insignia stripe help distinguish the fighter silhouettes.
	_add_visual_box(visual, "Belt", Vector3(0.5, 0.09, 0.35), Vector3(0, 0.82, 0), dark)
	_add_visual_box(visual, "Chest insignia", Vector3(0.16, 0.24, 0.035), Vector3(0.0, 1.22, -0.19), accent_mat)
	# Wrist wraps, forearm guards and knee panels.
	for side in [-1.0, 1.0]:
		_add_visual_box(visual, "Wrist wrap", Vector3(0.22, 0.12, 0.18), Vector3(side * 0.49, 0.91, -0.02), accent_mat)
		_add_visual_box(visual, "Knee panel", Vector3(0.26, 0.16, 0.10), Vector3(side * 0.18, 0.42, -0.13), accent_mat)
		_add_visual_box(visual, "Arm guard", Vector3(0.18, 0.22, 0.18), Vector3(side * 0.45, 1.02, -0.03), outfit)

func _add_visual_box(parent: Node3D, label: String, size: Vector3, pos: Vector3, material: Material) -> void:
	var instance := MeshInstance3D.new()
	instance.name = label
	var mesh := BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	instance.position = pos
	instance.material_override = material
	parent.add_child(instance)

func _add_visual_sphere(parent: Node3D, label: String, pos: Vector3, size: Vector3, material: Material) -> void:
	var instance := MeshInstance3D.new()
	instance.name = label
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	instance.mesh = mesh
	instance.scale = size
	instance.position = pos
	instance.material_override = material
	parent.add_child(instance)
