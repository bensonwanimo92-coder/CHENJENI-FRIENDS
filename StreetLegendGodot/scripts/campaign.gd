extends Node
class_name StreetLegendCampaign

signal level_unlocked(level_id: int)
signal level_completed(level_id: int)
signal campaign_finished

const SAVE_PATH := "user://street_legend_campaign.cfg"
const LEVELS := [
	{"id": 1, "title": "The Ambush", "location": "Hotel and roadblock", "objectives": ["Clear the hotel lobby", "Chase the Range Rover", "Defeat the roadblock crew"]},
	{"id": 2, "title": "The Pursuit", "location": "City streets and back alleys", "objectives": ["Track the escaping crew", "Survive street ambushes", "Reach the safe route"]},
	{"id": 3, "title": "The Hideout", "location": "Industrial compound", "objectives": ["Infiltrate the compound", "Clear security", "Rescue and protect the captive"]},
	{"id": 4, "title": "The Reckoning", "location": "Final enemy stronghold", "objectives": ["Fight through the stronghold", "Defeat the lieutenant", "Face the final boss"]}
]

var unlocked_level: int = 1
var completed_levels: Array[int] = []
var best_results: Dictionary = {}

func _ready() -> void:
	load_progress()

func level_data(level_id: int) -> Dictionary:
	if level_id < 1 or level_id > LEVELS.size():
		return {}
	return LEVELS[level_id - 1].duplicate(true)

func is_level_unlocked(level_id: int) -> bool:
	return level_id >= 1 and level_id <= unlocked_level and level_id <= LEVELS.size()

func complete_level(level_id: int, result: Dictionary = {}) -> bool:
	if not is_level_unlocked(level_id):
		return false
	if not completed_levels.has(level_id):
		completed_levels.append(level_id)
		level_completed.emit(level_id)
	if level_id < LEVELS.size() and unlocked_level < level_id + 1:
		unlocked_level = level_id + 1
		level_unlocked.emit(unlocked_level)
	if level_id == LEVELS.size():
		campaign_finished.emit()
	best_results[str(level_id)] = result.duplicate(true)
	save_progress()
	return true

func save_progress() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("campaign", "unlocked_level", unlocked_level)
	cfg.set_value("campaign", "completed_levels", completed_levels)
	cfg.set_value("campaign", "best_results", best_results)
	var err := cfg.save(SAVE_PATH)
	if err != OK:
		push_warning("Campaign progress save failed: %s" % err)

func load_progress() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	unlocked_level = clampi(int(cfg.get_value("campaign", "unlocked_level", 1)), 1, LEVELS.size())
	var saved = cfg.get_value("campaign", "completed_levels", [])
	completed_levels.clear()
	for value in saved:
		var id := int(value)
		if id >= 1 and id <= LEVELS.size() and not completed_levels.has(id):
			completed_levels.append(id)
	best_results = cfg.get_value("campaign", "best_results", {})
