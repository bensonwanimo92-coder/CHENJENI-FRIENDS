extends Node
class_name StreetLegendGameplayEvents

signal raised(event_type: StringName, actor: Node, target: Node, amount: float, heavy: bool)

func emit_event(event_type: StringName, actor: Node = null, target: Node = null, amount: float = 0.0, heavy: bool = false) -> void:
	raised.emit(event_type, actor, target, amount, heavy)
