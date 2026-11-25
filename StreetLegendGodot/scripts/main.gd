extends Node3D
const FighterScript = preload("res://scripts/fighter.gd")
const EnemyScript = preload("res://scripts/enemy_ai.gd")
const MobileControlsScript = preload("res://scripts/mobile_controls.gd")
var player: CharacterBody3D
var enemy: CharacterBody3D
var status_label: Label
func _ready() -> void:
	_build_world()
	_build_hud()
	player = _spawn_fighter("WANIMO", Vector3(-2.0, 0.0, 0.0), Color(0.08, 0.42, 0.82), true)
	enemy = _spawn_fighter("ROADBLOCK ENFORCER", Vector3(2.0, 0.0, 0.0), Color(0.72, 0.12, 0.10), false)
	enemy.set("target", player)
	player.connect("health_changed", Callable(self, "_on_player_health_changed"))
	player.set("opponent", enemy)
	var controls := Control.new()
	controls.set_script(MobileControlsScript)
	controls.set("fighter", player)
	add_child(controls)
	_update_status("HOTEL EXIT — FIRST ENCOUNTER")
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
	floor_body.name = "ArenaFloor"
	var floor_mesh := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(22, 18)
	floor_mesh.mesh = plane
	var floor_material := StandardMaterial3D.new()
	floor_material.albedo_color = Color(0.12, 0.15, 0.18)
	floor_material.roughness = 0.92
	floor_mesh.material_override = floor_material
	floor_body.add_child(floor_mesh)
	var floor_collision := CollisionShape3D.new()
	var floor_shape := BoxShape3D.new()
	floor_shape.size = Vector3(22, 0.2, 18)
	floor_collision.shape = floor_shape
	floor_collision.position.y = -0.1
	floor_body.add_child(floor_collision)
	add_child(floor_body)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -28, 0)
	sun.light_energy = 1.35
	add_child(sun)
	var camera := Camera3D.new()
	camera.name = "CombatCamera"
	camera.position = Vector3(0, 7.5, 10.5)
	camera.rotation_degrees = Vector3(-31, 0, 0)
	camera.current = true
	add_child(camera)
func _spawn_fighter(label: String, spawn: Vector3, tint: Color, is_player: bool) -> CharacterBody3D:
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
	return body
func _build_hud() -> void:
	var layer := CanvasLayer.new()
	var panel := PanelContainer.new()
	panel.position = Vector2(24, 20)
	panel.custom_minimum_size = Vector2(390, 86)
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
	help.text = "WASD / Arrows: move     SPACE: strike"
	column.add_child(help)
	add_child(layer)
func _on_player_health_changed(value: float) -> void:
	_update_status("WANIMO  •  HEALTH %d%%" % roundi(value))
func _update_status(message: String) -> void:
	if is_instance_valid(status_label):
		status_label.text = message
