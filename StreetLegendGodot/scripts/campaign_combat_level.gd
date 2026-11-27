extends Node3D
## Reusable standalone campaign combat mission for Levels 2-4.
const FighterScript = preload("res://scripts/fighter.gd")
const EnemyScript = preload("res://scripts/enemy_ai.gd")
const MobileControlsScript = preload("res://scripts/mobile_controls.gd")
const CameraScript = preload("res://scripts/third_person_camera.gd")
const AnimationDriverScript = preload("res://scripts/animation_driver.gd")
const FallRecoveryScript = preload("res://scripts/fall_recovery.gd")
@export var level_id:int=2
var player:CharacterBody3D
var enemies:Array[CharacterBody3D]=[]
var hud:Label
var controls:Node
var camera:Node3D
var defeated:int=0
var done:=false\nvar continue_button:Button
func _ready():
	_build_world()
	player=_fighter("WANIMO",Vector3(0,0,3),true,Color(0.1,0.4,0.85))
	camera=CameraScript.new()
	camera.position=Vector3(0,7,10)
	camera.current=true
	add_child(camera)
	camera.set("target",player)
	controls=MobileControlsScript.new()
	controls.set("fighter",player)
	controls.pause_requested.connect(_pause)
	add_child(controls)
	controls.call("set_driving_mode",false)
	var count=3 if level_id<4 else 4
	for i in count:
		var angle=TAU*float(i)/count
		var e=_fighter("CREW %02d"%(i+1),Vector3(cos(angle)*5,0,sin(angle)*5),false,Color(0.65,0.15,0.12))
		e.set_target(player)
		enemies.append(e)
		e.knocked_out.connect(_on_enemy_down)
		e.attack_event.connect(_event)
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
	var btn=Button.new()
	btn.text="RESTART MISSION"
	btn.pressed.connect(_restart)
	col.add_child(btn)
	_update_hud()
func _fighter(label:String,pos:Vector3,is_player:bool,tint:Color)->CharacterBody3D:
	var b=CharacterBody3D.new()
	b.name=label
	b.position=pos
	b.set_script(FighterScript if is_player else EnemyScript)
	b.set("is_player",is_player)
	b.set("display_name",label)
	if not is_player: b.set("attack_damage",10.0+level_id*2)
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
	var recover=Node.new()
	recover.set_script(FallRecoveryScript)
	b.add_child(recover)
	var c=CollisionShape3D.new()
	var capsule=CapsuleShape3D.new()
	capsule.height=1.8
	capsule.radius=.42
	c.shape=capsule
	c.position.y=.9
	b.add_child(c)
	add_child(b)
	return b
func _build_world():
	var env=WorldEnvironment.new()
	var e=Environment.new()
	e.background_mode=Environment.BG_COLOR
	e.background_color=Color(.04,.06,.09)
	env.environment=e
	add_child(env)
	var ground=StaticBody3D.new()
	var mesh=MeshInstance3D.new()
	var plane=PlaneMesh.new()
	plane.size=Vector2(40,40)
	mesh.mesh=plane
	ground.add_child(mesh)
	var collision=CollisionShape3D.new()
	var shape=BoxShape3D.new()
	shape.size=Vector3(40,.2,40)
	collision.shape=shape
	collision.position.y=-.1
	ground.add_child(collision)
	add_child(ground)
	var light=DirectionalLight3D.new()
	light.rotation_degrees=Vector3(-50,-30,0)
	add_child(light)
	# Environment identity and cover props vary by campaign mission.
	var colors=[Color(.2,.3,.35),Color(.28,.25,.18),Color(.12,.16,.19)]
	var material=StandardMaterial3D.new()
	material.albedo_color=colors[(level_id-2)%colors.size()]
	for i in 12:
		var prop=MeshInstance3D.new()
		var box=BoxMesh.new()
		box.size=Vector3(2+randf()*2,1+randf()*2,1.2)
		prop.mesh=box
		prop.position=Vector3(randf_range(-12,12),box.size.y/2,randf_range(-12,12))
		prop.material_override=material
		add_child(prop)
func _on_enemy_down():
	if done:return
	defeated+=1
	for e in enemies:
		if is_instance_valid(e) and e.get("health")>0:
			player.set_opponent(e)
			break
	if defeated>=enemies.size():
		done=true
		var campaign=get_node_or_null("/root/Campaign")
		if campaign:campaign.complete_level(level_id,{"result":"victory","defeated":defeated})
		hud.text="MISSION COMPLETE\nAll hostiles defeated. Level %d cleared."%level_id
	else:_update_hud()
func _continue():\n\tget_tree().paused=false\n\tget_tree().change_scene_to_file("res://scenes/level_%d.tscn"%(level_id+1))\nfunc _failed():
	if done:return
	done=true
	hud.text="MISSION FAILED\nRestart to try again."
func _update_hud():
	var title=["","","THE PURSUIT","THE HIDEOUT","THE RECKONING"][level_id]
	hud.text="%s\nHostiles remaining: %d\nTouch controls enabled."%[title,enemies.size()-defeated]
func _event(_event_type:StringName,_amount:float,_heavy:bool):pass
func _pause():
	get_tree().paused=not get_tree().paused
func _restart():
	get_tree().paused=false
	get_tree().reload_current_scene()
