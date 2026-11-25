extends Node
class_name StreetLegendAnimationDriver

@export var visual_root: Node3D
@export var animation_player: AnimationPlayer
@export var idle_animation: StringName = &"Idle"
@export var walk_animation: StringName = &"Walk"
@export var light_attack_animation: StringName = &"Jab"
@export var heavy_attack_animation: StringName = &"HeavyKick"
@export var hit_animation: StringName = &"HitReact"
@export var knockout_animation: StringName = &"Knockout"

var actor: Node
var _moving := false
var _knocked_out := false
var _home_rotation := Vector3.ZERO
var _reaction_tween: Tween

func _ready() -> void:
	actor = get_parent()
	if visual_root == null and actor is Node3D:
		visual_root = actor.get_node_or_null("PlaceholderBody") as Node3D
	if visual_root != null:
		_home_rotation = visual_root.rotation
	if actor != null and actor.has_signal("attack_event"):
		actor.attack_event.connect(_on_actor_event)

func _on_actor_event(event_type: StringName, _amount: float, heavy: bool) -> void:
	if _knocked_out:
		return
	match event_type:
		&"player_started_moving", &"opponent_started_moving":
			_moving = true
			_play_or_pose(walk_animation, Vector3.ZERO, 0.0)
		&"player_stopped_moving", &"opponent_stopped_moving":
			_moving = false
			_play_or_pose(idle_animation, Vector3.ZERO, 0.0)
		&"player_attack_started", &"opponent_started_attacking":
			_play_or_pose(heavy_attack_animation if heavy else light_attack_animation, Vector3(-0.12, 0.0, 0.0), 0.22)
		&"player_damaged", &"opponent_damaged", &"opponent_guarded":
			_play_or_pose(hit_animation, Vector3(0.0, 0.0, 0.18), 0.18)
		&"player_knocked_out", &"opponent_defeated":
			_knocked_out = true
			if not _play(knockout_animation):
				_fallback_knockout()

func _play_or_pose(animation_name: StringName, pose: Vector3, duration: float) -> void:
	if _play(animation_name):
		return
	if visual_root == null:
		return
	if _reaction_tween != null and _reaction_tween.is_running():
		_reaction_tween.kill()
	_reaction_tween = create_tween()
	_reaction_tween.tween_property(visual_root, "rotation", _home_rotation + pose, 0.09)
	_reaction_tween.tween_interval(duration)
	_reaction_tween.tween_property(visual_root, "rotation", _home_rotation, 0.14)

func _play(animation_name: StringName) -> bool:
	if animation_player == null or not is_instance_valid(animation_player):
		return false
	if not animation_player.has_animation(animation_name):
		return false
	animation_player.play(animation_name)
	return true

func _fallback_knockout() -> void:
	if visual_root == null:
		return
	if _reaction_tween != null and _reaction_tween.is_running():
		_reaction_tween.kill()
	_reaction_tween = create_tween()
	_reaction_tween.tween_property(visual_root, "rotation", _home_rotation + Vector3(1.15, 0.0, 0.0), 0.42)
