extends Control

const LEVEL_NAMES=["THE AMBUSH","THE PURSUIT","THE HIDEOUT","THE RECKONING"]
const LEVEL_TAGS=["HOTEL • ROADBLOCK","CITY • OPEN FIELD","INDUSTRIAL • RESCUE","FORTRESS • FINAL BOSS"]
const LEVEL_DESCRIPTIONS=["Fight through the hotel and survive the roadblock.","Track the fleeing convoy across a broad city battlefield.","Infiltrate the compound and rescue the captive.","Face the leader and finish the campaign."]

func _ready():
	_build()

func _style_button(button:Button,locked:bool,completed:bool):
	button.custom_minimum_size=Vector2(0,76)
	button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size",20)
	var normal=StyleBoxFlat.new()
	normal.bg_color=Color(0.07,0.12,0.19,0.96) if not locked else Color(0.045,0.065,0.09,0.9)
	normal.border_width_left=4
	normal.border_color=Color(0.08,0.78,0.95) if completed else Color(0.18,0.42,0.68) if not locked else Color(0.16,0.2,0.25)
	normal.corner_radius_top_left=12
	normal.corner_radius_top_right=12
	normal.corner_radius_bottom_left=12
	normal.corner_radius_bottom_right=12
	normal.content_margin_left=22
	normal.content_margin_right=22
	button.add_theme_stylebox_override("normal",normal)
	var hover=normal.duplicate()
	hover.bg_color=Color(0.12,0.22,0.31)
	button.add_theme_stylebox_override("hover",hover)
	button.add_theme_stylebox_override("pressed",hover)
	button.add_theme_stylebox_override("disabled",normal)
	button.add_theme_color_override("font_color",Color(0.82,0.94,1.0))
	button.add_theme_color_override("font_disabled_color",Color(0.38,0.43,0.48))

func _build():
	var bg=ColorRect.new()
	bg.color=Color(0.018,0.028,0.052)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var accent=ColorRect.new()
	accent.color=Color(0.02,0.58,0.78,0.75)
	accent.position=Vector2(0,0)
	accent.size=Vector2(0,5)
	accent.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	accent.size.y=5
	add_child(accent)
	var root=VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.offset_left=32
	root.offset_top=26
	root.offset_right=-32
	root.offset_bottom=-24
	root.add_theme_constant_override("separation",12)
	add_child(root)
	var header=HBoxContainer.new()
	header.alignment=BoxContainer.ALIGNMENT_CENTER
	root.add_child(header)
	var title=Label.new()
	title.text="STREET LEGEND"
	title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size",44)
	title.add_theme_color_override("font_color",Color(0.88,0.96,1.0))
	header.add_child(title)
	var sub=Label.new()
	sub.text="WANIMO  /  CAMPAIGN"
	sub.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size",16)
	sub.add_theme_color_override("font_color",Color(0.16,0.72,0.92))
	root.add_child(sub)
	var divider=ColorRect.new()
	divider.color=Color(0.08,0.42,0.61,0.6)
	divider.custom_minimum_size.y=2
	root.add_child(divider)
	var intro=Label.new()
	intro.text="SELECT YOUR MISSION"
	intro.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	intro.add_theme_font_size_override("font_size",18)
	intro.add_theme_color_override("font_color",Color(0.65,0.79,0.88))
	root.add_child(intro)
	var campaign=get_node("/root/Campaign")
	for i in 4:
		var id=i+1
		var button=Button.new()
		var unlocked=campaign.is_level_unlocked(id)
		var complete=campaign.completed_levels.has(id)
		var suffix="   •   COMPLETED" if complete else ("   •   LOCKED" if not unlocked else "   •   AVAILABLE")
		button.text="%02d  /  %s\\n%s%s"%(id,LEVEL_NAMES[i],LEVEL_TAGS[i],suffix)
		button.disabled=not unlocked
		_style_button(button,not unlocked,complete)
		button.pressed.connect(_launch.bind(id))
		root.add_child(button)
	var note=Label.new()
	note.text="\\n%s\\nProgress saves locally."%LEVEL_DESCRIPTIONS[0]
	note.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	note.add_theme_font_size_override("font_size",14)
	note.add_theme_color_override("font_color",Color(0.5,0.64,0.74))
	root.add_child(note)

func _launch(id):
	var paths=["","res://scenes/main.tscn","res://scenes/level_2.tscn","res://scenes/level_3.tscn","res://scenes/level_4.tscn"]
	get_tree().change_scene_to_file(paths[id])
