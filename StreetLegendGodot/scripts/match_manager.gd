extends Node
class_name StreetLegendMatchManager
var mission:Node
var _overlay:Control
var _message:Label
var _resume_button:Button
var _restart_button:Button
var _continue_button:Button
var _paused:=false
var _finished:=false
func _ready():
	process_mode=Node.PROCESS_MODE_ALWAYS
	_build_overlay()
func configure(mission_node:Node):
	mission=mission_node
	if mission and mission.has_signal("mission_finished"):
		mission.mission_finished.connect(_on_mission_finished)
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") and not _finished:
		_toggle_pause()
		get_viewport().set_input_as_handled()
func toggle_pause():
	if not _finished:_toggle_pause()
func _toggle_pause():
	_paused=not _paused
	get_tree().paused=_paused
	_overlay.visible=_paused
	_message.text="PAUSED" if _paused else ""
	_resume_button.visible=_paused
func _resume():
	if _finished:return
	_paused=false
	get_tree().paused=false
	_overlay.visible=false
func _on_mission_finished(victory:bool):
	_finished=true
	if victory and get_node_or_null("/root/Campaign"):
		get_node("/root/Campaign").complete_level(1,{"result":"victory"})
	get_tree().paused=false
	_overlay.visible=true
	_resume_button.visible=false
	_message.text="LEVEL 01 COMPLETE\nRoadblock cleared" if victory else "MISSION FAILED\nWanimo was knocked out"
	_restart_button.visible=not victory
	_continue_button.visible=victory
func _continue_campaign():
	get_tree().paused=false
	get_tree().change_scene_to_file("res://scenes/level_2.tscn")
func _restart():
	get_tree().paused=false
	get_tree().reload_current_scene()
func _build_overlay():
	var layer=CanvasLayer.new()
	layer.layer=100
	layer.process_mode=Node.PROCESS_MODE_ALWAYS
	add_child(layer)
	_overlay=ColorRect.new()
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.color=Color(.015,.025,.045,.88)
	_overlay.visible=false
	_overlay.process_mode=Node.PROCESS_MODE_ALWAYS
	layer.add_child(_overlay)
	var col=VBoxContainer.new()
	col.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	col.position=Vector2(-220,-160)
	col.size=Vector2(440,320)
	col.alignment=BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation",18)
	_overlay.add_child(col)
	_message=Label.new()
	_message.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	_message.add_theme_font_size_override("font_size",30)
	col.add_child(_message)
	_resume_button=Button.new()
	_resume_button.text="RESUME GAME"
	_resume_button.custom_minimum_size=Vector2(300,64)
	_resume_button.pressed.connect(_resume)
	col.add_child(_resume_button)
	_restart_button=Button.new()
	_restart_button.text="RESTART LEVEL"
	_restart_button.custom_minimum_size=Vector2(300,64)
	_restart_button.visible=false
	_restart_button.pressed.connect(_restart)
	col.add_child(_restart_button)
	_continue_button=Button.new()
	_continue_button.text="CONTINUE TO LEVEL 2"
	_continue_button.custom_minimum_size=Vector2(300,64)
	_continue_button.visible=false
	_continue_button.pressed.connect(_continue_campaign)
	col.add_child(_continue_button)
	var hint=Label.new()
	hint.text="ESC  •  PAUSE / RESUME"
	hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(hint)
