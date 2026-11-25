extends Node3D

const FighterScript = preload("res://scripts/fighter.gd")
const EnemyScript = preload("res://scripts/enemy_ai.gd")
const MobileControlsScript = preload("res://scripts/mobile_controls.gd")
const VehicleScript = preload("res://scripts/vehicle_controller.gd")
const ChaseScript = preload("res://scripts/chase_target.gd")
const CameraScript = preload("res://scripts/third_person_camera.gd")
const MissionScript = preload("res://scripts/mission_flow.gd")
const CommentatorScript = preload("res://scripts/commentator.gd")

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
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(1.9, 0.85, 3.7)
	mesh.mesh = box
	mesh.position.y = 0.65
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.06, 0.12, 0.18)
	material.metallic = 0.65
	material.roughness = 0.3
	mesh.material_override = material
	car.add_child(mesh)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.9, 0.85, 3.7)
	collision.shape = shape
	collision.position.y = 0.65
	car.add_child(collision)
	add_child(car)
	car.visible = false
	return car as StreetLegendVehicleController

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
