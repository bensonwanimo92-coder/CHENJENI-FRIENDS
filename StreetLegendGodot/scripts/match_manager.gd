extends Node
class_name StreetLegendMatchManager

var mission: Node
var _overlay: Control
var _message: Label
var _resume_button: Button
var _paused := false
var _finished := false
var _campaign_note := ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_overlay()

func configure(mission_node: Node) -> void:
	mission = mission_node
	if mission != null and mission.has_signal("mission_finished"):
		mission.mission_finished.connect(_on_mission_finished)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not _finished:
		_toggle_pause()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept") and _finished:
		_restart()
		get_viewport().set_input_as_handled()

func toggle_pause() -> void:
	if _finished:
		return
	_toggle_pause()

func _toggle_pause() -> void:
	_paused = not _paused
	get_tree().paused = _paused
	_overlay.visible = _paused
	_message.text = "PAUSED" if _paused else ""
	_resume_button.visible = _paused
	if _paused:
		_resume_button.grab_focus()

func _resume() -> void:
	if _finished:
		return
	_paused = false
	get_tree().paused = false
	_overlay.visible = false

func _on_mission_finished(victory: bool) -> void:
	_finished = true
	_campaign_note = ""
	if victory and get_node_or_null("/root/Campaign") != null:
		var campaign = get_node("/root/Campaign")
		campaign.complete_level(1, {"result": "victory"})
		_campaign_note = "\\nCampaign progress saved. Level 2 unlocked.";
	_paused = false
	get_tree().paused = false
	_overlay.visible = true
	_resume_button.visible = false
	_message.text = ("LEVEL 01 COMPLETE\nRoadblock cleared" if victory
		else "MISSION FAILED\nWanimo was knocked out")
	_restart_button.visible = true
	_restart_button.grab_focus()

func _continue_campaign() -> void:\n\tget_tree().paused = false\n\tget_tree().change_scene_to_file("res://scenes/level_2.tscn")\n\nfunc _restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

var _restart_button: Button\nvar _continue_button: Button

func _build_overlay() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 100
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(layer)
	_overlay = ColorRect.new()
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.color = Color(0.015, 0.025, 0.045, 0.88)
	_overlay.visible = false
	_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	layer.add_child(_overlay)
	var column := VBoxContainer.new()
	column.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	column.position = Vector2(-220, -140)
	column.size = Vector2(440, 280)
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 22)
	_overlay.add_child(column)
	_message = Label.new()
	_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_message.add_theme_font_size_override("font_size", 30)
	column.add_child(_message)
	_resume_button = Button.new()
	_resume_button.text = "RESUME GAME"
	_resume_button.custom_minimum_size = Vector2(300, 64)
	_resume_button.pressed.connect(_resume)
	column.add_child(_resume_button)
	_restart_button = Button.new()
	_restart_button.text = "RESTART LEVEL"
	_restart_button.custom_minimum_size = Vector2(300, 64)
	_restart_button.visible = false
	_restart_button.pressed.connect(_restart)
	column.add_child(_restart_button)
	var hint := Label.new()
	hint.text = "ESC  •  PAUSE / RESUME"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(hint)
