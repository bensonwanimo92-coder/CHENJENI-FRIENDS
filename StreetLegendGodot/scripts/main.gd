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
var commentator: StreetLegendCommentator
var match_manager: Node

func _ready() -> void:
	_build_world()
	_build_hud()
	player = _spawn_fighter("WANIMO", Vector3(-2.0, 0.0, 0.0), Color(0.08, 0.42, 0.82), true)
	hotel_enemy = _spawn_fighter("HOTEL ENFORCER", Vector3(2.0, 0.0, 0.0), Color(0.72, 0.12, 0.10), false)
	hotel_enemy.set_target(player)
	player.set("opponent", hotel_enemy)
	roadblock_enemy = _spawn_fighter("ROADBLOCK ENFORCER", Vector3(2.0, 0.0, -60.0), Color(0.68, 0.16, 0.12), false)
	roadblock_enemy.visible = false
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
	player.attack_event.connect(_on_combat_event)
	hotel_enemy.attack_event.connect(_on_combat_event)
	roadblock_enemy.attack_event.connect(_on_combat_event)
	commentator = CommentatorScript.new()
	add_child(commentator)
	roadblock_enemy.knocked_out.connect(mission.notify_roadblock_enemy_defeated)
	player.knocked_out.connect(mission.notify_player_defeated)
	mission.phase_changed.connect(_on_mission_phase_changed)
	mission.mission_finished.connect(_on_mission_finished)
	match_manager = MatchManagerScript.new()
	match_manager.name = "MatchManager"
	add_child(match_manager)
	match_manager.call("configure", mission)
	controls = MobileControlsScript.new()
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

func _spawn_fighter(label: String, spawn: Vector3, tint: Color, is_player: bool) -> StreetLegendFighter:
	var body := CharacterBody3D.new()
	body.name = label.replace(" ", "")
	body.position = spawn
	body.set_script(FighterScript if is_player else EnemyScript)
	body.set("is_player", is_player)
	body.set("display_name", label)
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.42
	capsule.height = 1.8
	var mesh := MeshInstance3D.new()
	mesh.name = "PlaceholderBody"
	mesh.mesh = capsule
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.metallic = 0.05
	material.roughness = 0.72
	mesh.material_override = material
	mesh.position.y = 0.9
	body.add_child(mesh)
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

func _spawn_chase_target() -> StreetLegendChaseTarget:
	var rover := Node3D.new()
	rover.name = "EscapingRangeRover"
	rover.set_script(ChaseScript)
	rover.position = Vector3(0.0, 0.0, -23.0)
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(2.0, 1.0, 4.2)
	mesh.mesh = box
	mesh.position.y = 0.7
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.12, 0.13, 0.15)
	material.metallic = 0.55
	material.roughness = 0.28
	mesh.material_override = material
	rover.add_child(mesh)
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
	var help := Label.new()
	help.text = "Touch joystick + strike buttons  •  Landscape mode"
	column.add_child(help)
	add_child(layer)

func _on_mission_phase_changed(new_phase: StringName) -> void:
	if new_phase == &"driving_pursuit":
		controls.call("set_driving_mode", true)
		camera_rig.set("target", vehicle)
		_update_status("PURSUIT  •  THE RANGE ROVER IS PULLING AWAY")
	elif new_phase == &"roadblock_combat":
		controls.call("set_driving_mode", false)
		camera_rig.set("target", player)
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
	_update_status("WANIMO  •  HEALTH %d%%" % roundi(value))

func _update_status(message: String) -> void:
	if is_instance_valid(status_label):
		status_label.text = message

func _build_lobby_set() -> void:
	# Temporary procedural architectural set dressing; replace these meshes with licensed assets.
	var wall_mat := StandardMaterial3D.new()
	wall_mat.albedo_color = Color(0.28, 0.31, 0.35)
	wall_mat.roughness = 0.85
	var trim_mat := StandardMaterial3D.new()
	trim_mat.albedo_color = Color(0.55, 0.48, 0.34)
	trim_mat.metallic = 0.25
	trim_mat.roughness = 0.55
	var glass_mat := StandardMaterial3D.new()
	glass_mat.albedo_color = Color(0.12, 0.24, 0.31, 0.65)
	glass_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass_mat.roughness = 0.25
	# Side pillars frame a clear central fighting space.
	for x in [-8.0, 8.0]:
		for z in [-5.0, 3.0]:
			var pillar := MeshInstance3D.new()
			var pm := BoxMesh.new()
			pm.size = Vector3(1.1, 5.0, 1.1)
			pillar.mesh = pm
			pillar.position = Vector3(x, 2.5, z)
			pillar.material_override = trim_mat
			add_child(pillar)
	# Lobby rear wall and glazed panels.
	var rear := MeshInstance3D.new()
	var rm := BoxMesh.new()
	rm.size = Vector3(18.0, 5.0, 0.45)
	rear.mesh = rm
	rear.position = Vector3(0.0, 2.5, -9.0)
	rear.material_override = wall_mat
	add_child(rear)
	for x in [-5.0, -2.5, 2.5, 5.0]:
		var pane := MeshInstance3D.new()
		var gm := BoxMesh.new()
		gm.size = Vector3(2.0, 3.2, 0.08)
		pane.mesh = gm
		pane.position = Vector3(x, 2.1, -8.72)
		pane.material_override = glass_mat
		add_child(pane)
	# Reception counter set to the side, not across the combat route.
	var counter := MeshInstance3D.new()
	var cm := BoxMesh.new()
	cm.size = Vector3(4.5, 1.2, 1.1)
	counter.mesh = cm
	counter.position = Vector3(-5.0, 0.6, -5.5)
	counter.material_override = trim_mat
	add_child(counter)
	# Seating clusters at the lobby edges.
	for x in [-6.5, 6.5]:
		var seat := MeshInstance3D.new()
		var sm := BoxMesh.new()
		sm.size = Vector3(2.4, 0.55, 0.9)
		seat.mesh = sm
		seat.position = Vector3(x, 0.4, 0.0)
		seat.material_override = wall_mat
		add_child(seat)
		var back := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(2.4, 0.9, 0.25)
		back.mesh = bm
		back.position = Vector3(x, 0.95, -0.35)
		back.material_override = wall_mat
		add_child(back)
	# Decorative ceiling beams.
	for x in [-6.0, -3.0, 0.0, 3.0, 6.0]:
		var beam := MeshInstance3D.new()
		var bmesh := BoxMesh.new()
		bmesh.size = Vector3(0.35, 0.25, 12.0)
		beam.mesh = bmesh
		beam.position = Vector3(x, 5.1, -2.0)
		beam.material_override = trim_mat
		add_child(beam)
