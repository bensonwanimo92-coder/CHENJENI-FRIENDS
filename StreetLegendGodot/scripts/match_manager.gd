extends Node
class_name StreetLegendMatchManager

var mission: Node
var _overlay: Control
var _message: Label
var _paused := false
var _finished := false

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

func _toggle_pause() -> void:
	_paused = not _paused
	get_tree().paused = _paused
	_overlay.visible = _paused
	_message.text = "PAUSED\nPress Escape to resume" if _paused else ""

func _on_mission_finished(victory: bool) -> void:
	_finished = true
	_paused = false
	get_tree().paused = false
	_overlay.visible = true
	_message.text = ("LEVEL 01 COMPLETE\nRoadblock cleared\nPress Enter to restart" if victory
		else "MISSION FAILED\nWanimo was knocked out\nPress Enter to retry")

func _restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _build_overlay() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	_overlay = ColorRect.new()
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.color = Color(0.015, 0.025, 0.045, 0.9)
	_overlay.visible = false
	layer.add_child(_overlay)
	var column := VBoxContainer.new()
	column.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	column.position = Vector2(-300, -90)
	column.size = Vector2(600, 180)
	_overlay.add_child(column)
	_message = Label.new()
	_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_message.add_theme_font_size_override("font_size", 30)
	column.add_child(_message)
	var hint := Label.new()
	hint.text = "ESC  •  PAUSE / RESUME     ENTER  •  RESTART"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(hint)
