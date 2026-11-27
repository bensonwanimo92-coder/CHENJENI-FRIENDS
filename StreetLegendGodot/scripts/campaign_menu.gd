extends Control
func _ready():
	_build()
func _build():
	var bg=ColorRect.new()
	bg.color=Color(.025,.04,.075)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var center=VBoxContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	center.position=Vector2(-300,-240)
	center.size=Vector2(600,480)
	center.alignment=BoxContainer.ALIGNMENT_CENTER
	center.add_theme_constant_override("separation",16)
	add_child(center)
	var title=Label.new()
	title.text="STREET LEGEND"
	title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size",48)
	center.add_child(title)
	var sub=Label.new()
	sub.text="CAMPAIGN • WANIMO"
	sub.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(sub)
	var campaign=get_node("/root/Campaign")
	for i in 4:
		var id=i+1
		var info=campaign.level_data(id)
		var button=Button.new()
		var unlocked=campaign.is_level_unlocked(id)
		var complete=campaign.completed_levels.has(id)
		button.text="%02d  •  %s%s"%(id,info.title,"  ✓" if complete else (" " if unlocked else "  LOCKED"))
		button.custom_minimum_size=Vector2(540,76)
		button.disabled=not unlocked
		button.pressed.connect(_launch.bind(id))
		center.add_child(button)
	var note=Label.new()
	note.text="Progress is saved locally on this device."
	note.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(note)
func _launch(id):
	var paths=["","res://scenes/main.tscn","res://scenes/level_2.tscn","res://scenes/level_3.tscn","res://scenes/level_4.tscn"]
	get_tree().change_scene_to_file(paths[id])
