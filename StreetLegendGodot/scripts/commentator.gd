extends Node
class_name StreetLegendCommentator

@export var commentary_enabled: bool = true
@export var subtitles_enabled: bool = true
@export_range(0.0, 1.0) var voice_volume: float = 0.9
@export var subtitle_hold_seconds: float = 3.2
var audio_player: AudioStreamPlayer
var subtitle_label: Label
var cooldowns: Dictionary = {}
var line_queue: Array[Dictionary] = []
var speaking := false
var default_lines := {
	&"player_attack_started": ["He's committing to the strike!", "Here comes the attack. Watch the timing."],
	&"player_attack_missed": ["That one misses. He needs better distance."],
	&"player_hit_confirmed": ["Clean connection! That's how you make it count.", "A solid hit lands."],
	&"player_damaged": ["He felt that one. Stay sharp!"],
	&"opponent_started_attacking": ["Incoming attack! Read the opponent's movement."],
	&"opponent_defeated": ["The enforcer is down! That's a win."],
	&"player_knocked_out": ["He's down! The round is over."],
	&"roadblock_reached": ["The road is blocked! He's got to get out and fight."]
}

func _ready() -> void:
	audio_player = AudioStreamPlayer.new()
	audio_player.volume_db = linear_to_db(voice_volume)
	add_child(audio_player)
	if subtitles_enabled:
		subtitle_label = Label.new()
		subtitle_label.name = "CommentarySubtitles"
		subtitle_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		subtitle_label.offset_top = -105.0
		subtitle_label.offset_bottom = -35.0
		subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		subtitle_label.add_theme_font_size_override("font_size", 24)
		add_child(subtitle_label)

func announce(event_type: StringName, custom_text: String = "", cooldown: float = 0.8) -> void:
	if not commentary_enabled:
		return
	var now := Time.get_ticks_msec() / 1000.0
	if now < float(cooldowns.get(event_type, 0.0)):
		return
	cooldowns[event_type] = now + cooldown
	var choices: Array = default_lines.get(event_type, [])
	var line := custom_text if not custom_text.is_empty() else (str(choices.pick_random()) if not choices.is_empty() else "")
	if line.is_empty():
		return
	line_queue.append({"text": line})
	if not speaking:
		_play_next()

func _play_next() -> void:
	if line_queue.is_empty():
		speaking = false
		return
	speaking = true
	var item: Dictionary = line_queue.pop_front()
	var line: String = item["text"]
	if subtitles_enabled and is_instance_valid(subtitle_label):
		subtitle_label.text = line
	# Audio clips can be assigned later; Android TTS integration is deliberately kept
	# behind an explicit platform adapter rather than pretending a voice is bundled.
	await get_tree().create_timer(clampf(float(line.length()) * 0.065, 1.8, 5.5)).timeout
	if is_instance_valid(subtitle_label):
		subtitle_label.text = ""
	_play_next()
