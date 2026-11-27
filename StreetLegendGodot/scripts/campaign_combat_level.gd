extends Node3D
## Combat mission scene scaffold shared by campaign missions 2-4.
const FighterScript=preload("res://scripts/fighter.gd")
const EnemyScript=preload("res://scripts/enemy_ai.gd")
const MobileControlsScript=preload("res://scripts/mobile_controls.gd")
const CameraScript=preload("res://scripts/third_person_camera.gd")
const AnimationDriverScript=preload("res://scripts/animation_driver.gd")
const FallRecoveryScript=preload("res://scripts/fall_recovery.gd")
@export var level_id:int=2
var player:StreetLegendFighter
var enemies:Array[StreetLegendFighter]=[]
var hud:Label
var defeated:int=0
var done:=false
var continue_button:Button
var rescue_button:Button
var captive:Node3D
var field_props:Array[Node3D]=[]
func _ready():
	_build_world()
	player=_fighter("WANIMO",Vector3(0,0,3),true,Color(.1,.4,.85))
	var camera=CameraScript.new()
	camera.position=Vector3(0,7,10)
	camera.current=true
	add_child(camera)
	camera.set("target",player)
	var controls=MobileControlsScript.new()
	controls.set("fighter",player)
	controls.pause_requested.connect(_pause)
	add_child(controls)
	controls.call("set_driving_mode",false)
	var count=6 if level_id==2 else (5 if level_id==3 else 4)
	for i in count:
		var angle=TAU*float(i)/count
		var foe=_fighter("CREW %02d"%(i+1),Vector3(cos(angle)*8,0,sin(angle)*8),false,Color(.65,.15,.12))
		foe.set_target(player)
		enemies.append(foe)
		foe.knocked_out.connect(_on_enemy_down)
	player.set_opponent(_nearest_living_enemy())
	player.knocked_out.connect(_failed)
	var layer=CanvasLayer.new()
	add_child(layer)
	var panel=PanelContainer.new()
	panel.position=Vector2(20,20)
	layer.add_child(panel)
	var col=VBoxContainer.new()
	panel.add_child(col)
	hud=Label.new()
	col.add_child(hud)
	continue_button=Button.new()
	continue_button.text="CONTINUE CAMPAIGN"
	continue_button.visible=false
	continue_button.pressed.connect(_continue)
	col.add_child(continue_button)
	rescue_button=Button.new()
	rescue_button.text="RESCUE CAPTIVE"
	rescue_button.visible=false
	rescue_button.pressed.connect(_rescue)
	col.add_child(rescue_button)
	var retry=Button.new()
	retry.text="RESTART MISSION"
	retry.pressed.connect(_restart)
	col.add_child(retry)
	if level_id==3:_build_captive()
	_update_hud()
func _fighter(label:String,pos:Vector3,is_player:bool,tint:Color)->StreetLegendFighter:
	var b=CharacterBody3D.new()
	b.name=label
	b.position=pos
	b.set_script(FighterScript if is_player else EnemyScript)
	b.set("is_player",is_player)
	b.set("display_name",label)
	if not is_player:
		b.set("attack_damage",10.0+level_id*2)
		if level_id==4 and label=="CREW 01":
			b.set("max_health",220.0)
			b.set("attack_damage",24.0)
			b.set("move_speed",3.3)
	var visual=Node3D.new()
	visual.name="FighterVisual"
	b.add_child(visual)
	# Replace these paths with licensed rigged GLB assets as they become available.
	var model_path="res://assets/fighters/player.glb" if is_player else ("res://assets/fighters/boss.glb" if level_id==4 and label=="CREW 01" else "res://assets/fighters/enemy.glb")
	var imported:PackedScene=load(model_path) if ResourceLoader.exists(model_path) else null
	if imported:
		var model=imported.instantiate()
		model.name="Imported3DCharacter"
		visual.add_child(model)
	else:
		# Keep procedural fallback until imported models exist.
		var mat=StandardMaterial3D.new()
		mat.albedo_color=tint
		for spec in [[Vector3(0,1.2,0),Vector3(.65,.7,.35)],[Vector3(0,1.7,0),Vector3(.38,.38,.38)],[Vector3(-.2,.4,0),Vector3(.22,.7,.25)],[Vector3(.2,.4,0),Vector3(.22,.7,.25)],[Vector3(-.4,1.1,0),Vector3(.2,.65,.2)],[Vector3(.4,1.1,0),Vector3(.2,.65,.2)]]:
			var m=MeshInstance3D.new()
			var mesh=BoxMesh.new()
			mesh.size=spec[1]
			m.mesh=mesh
			m.position=spec[0]
			m.material_override=mat
			visual.add_child(m)
	var anim=Node.new()
	anim.set_script(AnimationDriverScript)
	b.add_child(anim)
	var recovery=Node.new()
	recovery.set_script(FallRecoveryScript)
	b.add_child(recovery)
	var collision=CollisionShape3D.new()
	var shape=CapsuleShape3D.new()
	shape.height=1.8
	shape.radius=.42
	collision.shape=shape
	collision.position.y=.9
	b.add_child(collision)
	add_child(b)
	return b as StreetLegendFighter
func _build_world():
	var environment=WorldEnvironment.new()
	var env=Environment.new()
	env.background_mode=Environment.BG_COLOR
	env.background_color=Color(.04,.06,.09)
	environment.environment=env
	add_child(environment)
	# Imported environment scenes are loaded first when present. Procedural fallback below
	# keeps missions playable while real, licensed GLB assets are added to the folders.
	_load_environment_asset("res://assets/environment/road.glb",Vector3(0,0,0))
	_load_environment_asset("res://assets/environment/buildings.glb",Vector3(0,0,0))
	_load_environment_asset("res://assets/environment/bridge.glb",Vector3(0,0,-12))
	_load_environment_asset("res://assets/vehicles/vehicle.glb",Vector3(6,0,5))
	var floor=StaticBody3D.new()
	var floor_mesh=MeshInstance3D.new()
	var plane=PlaneMesh.new()
	plane.size=Vector2(60,60)
	floor_mesh.mesh=plane
	floor_mesh.material_override=_surface_material(Color(.17,.19,.2))
	floor.add_child(floor_mesh)
	var collision=CollisionShape3D.new()
	var box_shape=BoxShape3D.new()
	box_shape.size=Vector3(60,.2,60)
	collision.shape=box_shape
	collision.position.y=-.1
	floor.add_child(collision)
	add_child(floor)
	_build_road()
	_build_buildings()
	_build_bridge()
	_build_vehicle()
	var sun=DirectionalLight3D.new()
	sun.rotation_degrees=Vector3(-50,-30,0)
	sun.light_energy=1.25
	add_child(sun)
	var palette=[Color(.2,.3,.35),Color(.28,.25,.18),Color(.12,.16,.19)]
	var material=StandardMaterial3D.new()
	material.albedo_color=palette[level_id-2]
	for i in 16:
		var prop=MeshInstance3D.new()
		var prop_mesh=BoxMesh.new()
		prop_mesh.size=Vector3(2+randf()*2,1+randf()*2,1.2)
		prop.mesh=prop_mesh
		prop.position=Vector3(randf_range(-15,15),prop_mesh.size.y/2,randf_range(-15,15))
		prop.material_override=material
		add_child(prop)

func _load_environment_asset(path:String,offset:Vector3):
	if ResourceLoader.exists(path):
		var scene=load(path) as PackedScene
		if scene:
			var node=scene.instantiate()
			node.position=offset
			add_child(node)

func _surface_material(color:Color)->StandardMaterial3D:
	var mat=StandardMaterial3D.new()
	mat.albedo_color=color
	mat.roughness=.92
	return mat

func _build_road():
	var road=MeshInstance3D.new()
	var mesh=BoxMesh.new()
	mesh.size=Vector3(9,.08,60)
	road.mesh=mesh
	road.position=Vector3(0,.03,0)
	road.material_override=_surface_material(Color(.07,.075,.08))
	add_child(road)
	for lane in [-1,1]:
		var stripe=MeshInstance3D.new()
		var line=BoxMesh.new()
		line.size=Vector3(.16,.035,60)
		stripe.mesh=line
		stripe.position=Vector3(lane*4.1,.09,0)
		stripe.material_override=_surface_material(Color(.82,.76,.53))
		add_child(stripe)
	for z in range(-28,29,5):
		var dash=MeshInstance3D.new()
		var dash_mesh=BoxMesh.new()
		dash_mesh.size=Vector3(.16,.04,2.5)
		dash.mesh=dash_mesh
		dash.position=Vector3(0,.1,z)
		dash.material_override=_surface_material(Color(.9,.86,.72))
		add_child(dash)

func _build_buildings():
	for i in 6:
		var building=Node3D.new()
		var width=randf_range(5,9)
		var height=randf_range(5,13)
		var depth=randf_range(5,9)
		building.position=Vector3(-17 if i%2==0 else 17,0,-20+i*8)
		var shell=MeshInstance3D.new()
		var box=BoxMesh.new()
		box.size=Vector3(width,height,depth)
		shell.mesh=box
		shell.position.y=height/2
		shell.material_override=_surface_material(Color(.27,.29,.3))
		building.add_child(shell)
		# Window grids and ground-floor openings provide façade detail.
		for row in range(1,int(height/2)):
			for col in range(2):
				var window=MeshInstance3D.new()
				var wmesh=BoxMesh.new()
				wmesh.size=Vector3(.8,.65,.08)
				window.mesh=wmesh
				window.position=Vector3((col-.5)*width*.5,row*1.65,depth/2+.05)
				window.material_override=_surface_material(Color(.12,.35,.48))
				building.add_child(window)
		add_child(building)

func _build_bridge():
	var bridge=Node3D.new()
	bridge.position=Vector3(0,0,-13)
	var deck=MeshInstance3D.new()
	var dm=BoxMesh.new()
	dm.size=Vector3(12,.45,8)
	deck.mesh=dm
	deck.position.y=1.2
	deck.material_override=_surface_material(Color(.35,.37,.38))
	bridge.add_child(deck)
	for x in [-5.5,5.5]:
		var rail=MeshInstance3D.new()
		var rm=BoxMesh.new()
		rm.size=Vector3(.35,1.1,8)
		rail.mesh=rm
		rail.position=Vector3(x,1.9,0)
		rail.material_override=_surface_material(Color(.18,.21,.22))
		bridge.add_child(rail)
	add_child(bridge)

func _build_vehicle():
	var vehicle=Node3D.new()
	vehicle.position=Vector3(6,0,5)
	var body=MeshInstance3D.new()
	var bm=BoxMesh.new()
	bm.size=Vector3(2,1,4)
	body.mesh=bm
	body.position.y=1
	body.material_override=_surface_material(Color(.24,.28,.32))
	vehicle.add_child(body)
	for x in [-.9,.9]:
		for z in [-1.3,1.3]:
			var wheel=MeshInstance3D.new()
			var wm=CylinderMesh.new()
			wm.height=.4
			wm.radius=.45
			wheel.mesh=wm
			wheel.rotation_degrees.z=90
			wheel.position=Vector3(x,.45,z)
			wheel.material_override=_surface_material(Color(.035,.04,.045))
			vehicle.add_child(wheel)
	add_child(vehicle)
func _on_enemy_down():
	if done:return
	defeated+=1
	for foe in enemies:
		if is_instance_valid(foe) and foe.health>0:
			player.set_opponent(foe)
			break
	if defeated>=enemies.size():
		if level_id==3:
			hud.text="COMPOUND CLEARED\nRescue the captive to finish."
			rescue_button.visible=true
		else:_finish_mission()
	else:_update_hud()
func _build_captive():
	captive=Node3D.new()
	captive.position=Vector3(0,0,-4)
	var body=MeshInstance3D.new()
	var mesh=BoxMesh.new()
	mesh.size=Vector3(.45,1.1,.3)
	body.mesh=mesh
	var material=StandardMaterial3D.new()
	material.albedo_color=Color(.2,.7,.65)
	body.material_override=material
	captive.add_child(body)
	add_child(captive)
func _rescue():
	if is_instance_valid(captive):captive.queue_free()
	rescue_button.visible=false
	_finish_mission()
func _finish_mission():
	if done:return
	done=true
	var campaign=get_node_or_null("/root/Campaign")
	if campaign:campaign.complete_level(level_id,{"result":"victory","defeated":defeated})
	hud.text="MISSION COMPLETE\nLevel %d cleared."%level_id
	continue_button.visible=level_id<4
	if level_id<4:continue_button.text="CONTINUE TO LEVEL %d"%(level_id+1)
func _continue():
	get_tree().paused=false
	get_tree().change_scene_to_file("res://scenes/level_%d.tscn"%(level_id+1))
func _failed():
	if done:return
	done=true
	hud.text="MISSION FAILED\nRestart to try again."
func _update_hud():
	var title=["","","THE PURSUIT","THE HIDEOUT","THE RECKONING"][level_id]
	hud.text="%s\nHostiles remaining: %d"%[title,enemies.size()-defeated]
func _pause():get_tree().paused=not get_tree().paused
func _restart():
	get_tree().paused=false
	get_tree().reload_current_scene()
