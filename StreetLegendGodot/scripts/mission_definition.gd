extends Resource
class_name StreetLegendMissionDefinition

@export var level_id: int = 1
@export var mission_title: String = ""
@export_multiline var briefing: String = ""
@export var objectives: Array[String] = []
@export var checkpoint_ids: Array[String] = []
@export var scene_path: String = ""
@export var reward_cash: int = 0

func is_valid_definition() -> bool:
	return level_id >= 1 and level_id <= 4 and not mission_title.is_empty() and not scene_path.is_empty() and not objectives.is_empty()
