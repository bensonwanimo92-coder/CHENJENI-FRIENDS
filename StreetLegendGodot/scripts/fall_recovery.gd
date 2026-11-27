extends Node
class_name StreetLegendFallRecovery

@export var fall_threshold: float = -8.0
@export var recovery_cooldown: float = 1.0
@export var checkpoint: Node3D
@export var disable_if_no_checkpoint: bool = false

var actor: CharacterBody3D
var _fallback_transform: Transform3D
var _next_recovery_time: float = 0.0

func _ready() -> void:
	actor = get_parent() as CharacterBody3D
	if actor != null:
		_fallback_transform = actor.global_transform

func _physics_process(_delta: float) -> void:
	if actor == null or not is_instance_valid(actor):
		return
	if actor.global_position.y >= fall_threshold or Time.get_ticks_msec() < _next_recovery_time:
		return
	_next_recovery_time = Time.get_ticks_msec() + int(recovery_cooldown * 1000.0)
	if checkpoint == null and disable_if_no_checkpoint:
		actor.queue_free()
		return
	actor.global_transform = checkpoint.global_transform if is_instance_valid(checkpoint) else _fallback_transform
	actor.velocity = Vector3.ZERO
	if actor.has_method("reset_vertical_motion"):
		actor.reset_vertical_motion()
