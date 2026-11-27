extends Node3D
## Combat mission scene scaffold shared by campaign missions 2-4.
const FighterScript=preload("res://scripts/fighter.gd")
const EnemyScript=preload("res://scripts/enemy_ai.gd")
const MobileControlsScript=preload("res://scripts/mobile_controls.gd")
const CameraScript=preload("res://scripts/third_person_camera.gd")
const AnimationDriverScript=preload("res://scripts/animation_driver.gd")
const FallRecoveryScript=preload("res://scripts/fall_recovery.gd")
@export var level_id:int=2
var player:CharacterBody3D
var enemies:Array[CharacterBody3D]=[]
var hud:Label
var defeated:int=0
var done:=false
var continue_button:Button
var rescue_button:Button
var captive:Node3D
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
	var count=4 if level_id==4 else 3
	for i in count:
		var angle=TAU*float(i)/count
		var foe=_fighter("CREW %02d"%(i+1),Vector3(cos(angle)*5,0,sin(angle)*5),false,Color(.65,.15,.12))
		foe.set_target(player)
		enemies.append(foe)
		foe.knocked_out.connect(_on_enemy_down)
	player.set_opponent(enemies[0])
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
func _fighter(label:String,pos:Vector3,is_player:bool,tint:Color)->CharacterBody3D:
	var b=CharacterBody3D.new()
	b.name=label
	b.position=pos
	b.set_script(FighterScript if is_player else EnemyScript)
	b.set("is_player",is_player)
	b.set("display_name",label)
	if not is_player:\n\t\tb.set("attack_damage",10.0+level_id*2)\n\t\tif level_id==4 and label=="CREW 01":\n\t\t\tb.set("max_health",220.0)\n\t\t\tb.set("attack_damage",24.0)\n\t\t\tb.set("move_speed",3.3)
	var visual=Node3D.new()
	visual.name="PlaceholderBody"
	b.add_child(visual)
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
	return b
func _build_world():
	var environment=WorldEnvironment.new()
	var env=Environment.new()
	env.background_mode=Environment.BG_COLOR
	env.background_color=Color(.04,.06,.09)
	environment.environment=env
	add_child(environment)
	var floor=StaticBody3D.new()
	var floor_mesh=MeshInstance3D.new()
	var plane=PlaneMesh.new()
	plane.size=Vector2(40,40)
	floor_mesh.mesh=plane
	floor.add_child(floor_mesh)
	var collision=CollisionShape3D.new()
	var box_shape=BoxShape3D.new()
	box_shape.size=Vector3(40,.2,40)
	collision.shape=box_shape
	collision.position.y=-.1
	floor.add_child(collision)
	add_child(floor)
	var sun=DirectionalLight3D.new()
	sun.rotation_degrees=Vector3(-50,-30,0)
	add_child(sun)
	var palette=[Color(.2,.3,.35),Color(.28,.25,.18),Color(.12,.16,.19)]
	var material=StandardMaterial3D.new()
	material.albedo_color=palette[level_id-2]
	for i in 12:
		var prop=MeshInstance3D.new()
		var prop_mesh=BoxMesh.new()
		prop_mesh.size=Vector3(2+randf()*2,1+randf()*2,1.2)
		prop.mesh=prop_mesh
		prop.position=Vector3(randf_range(-12,12),prop_mesh.size.y/2,randf_range(-12,12))
		prop.material_override=material
		add_child(prop)
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
